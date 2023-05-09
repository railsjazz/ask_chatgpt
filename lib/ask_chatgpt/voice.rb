module StringExt
  refine String do
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def green;          "\e[32m#{self}\e[0m" end
    def brown;          "\e[33m#{self}\e[0m" end
    def blue;           "\e[34m#{self}\e[0m" end
    def magenta;        "\e[35m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
    def gray;           "\e[37m#{self}\e[0m" end
  end
end

using StringExt

module AskChatgpt
  module VoiceFlow
    require 'io/console'
    require 'fileutils'
    require 'timeout'
    require 'open3'

    class AudioRecorder
      OUTPUT_FILE = "output.wav"

      def initialize(duration)
        @duration = duration
      end

      # ffmpeg -f avfoundation -list_devices true -i ""
      def audio_device_id
        AskChatGPT.audio_device_id
      end

      def start
        delete_audio_file
        ffmpeg_command = build_ffmpeg_command
        @stdin, @stdout_and_stderr, @wait_thread = Open3.popen2e(ffmpeg_command)
      end

      def stop
        @stdin.puts 'q'
        @stdin.close
        @stdout_and_stderr.close
        sleep(0.2)
      rescue Errno::EPIPE, IOError
      end

      def delete_audio_file
        FileUtils.rm(OUTPUT_FILE) if File.exist?(OUTPUT_FILE)
      end

      private

      def build_ffmpeg_command
        case RUBY_PLATFORM
        when /darwin/
          input_device = "-f avfoundation -i \":#{audio_device_id}\""
        when /linux/
          input_device = '-f alsa -i default'
        when /mingw|mswin/
          input_device = '-f dshow -i audio="Microphone (Realtek High Definition Audio)"'
        else
          raise "Unsupported platform: #{RUBY_PLATFORM}"
        end

        "ffmpeg -loglevel quiet #{input_device} -t #{@duration} #{OUTPUT_FILE}"
      end
    end

    class Voice
      def initialize
        @messages = []
        @wanna_quit = false
        @duration = (AskChatGPT.voice_max_duration.presence || 10).to_i
        @ffmpeg_wait_duration = 0.5
        @executing = true
        @spinner = nil
      end

      def run
        while @executing
          # Start the parallel process
          audio_recorder = AudioRecorder.new(@duration)
          audio_recorder.start

          begin
            Timeout.timeout(@duration + @ffmpeg_wait_duration) do
              @spinner = TTY::Spinner.new("[Recording]".red + " / Press any key to stop recording or \"Esc\" / \"q\" to quit ... ".blue + ":spinner".red, format: :spin)
              @spinner.auto_spin
              sleep(@ffmpeg_wait_duration) # five some time for ffmpeg to start
              # Listen for user input in the main process
              begin
                char = $stdin.getch
                if char.ord == 27 || char.upcase == "Q"
                  audio_recorder.stop
                  @executing = false
                  @spinner.stop
                  puts "Bye...".brown
                end
                break
              end while char.nil?
            end
          rescue Timeout::Error
          ensure
            audio_recorder.stop
            @spinner.stop
            break unless @executing
          end

          if !File.exist?("output.wav")
            puts "No audio file found, please try again.".brown
            sleep(0.5)
            next
          end

          @spinner = TTY::Spinner.new("Thinking :spinner".cyan, format: :dots)
          @spinner.auto_spin
          response = client.transcribe(parameters: { model: "whisper-1", file: File.open("output.wav", "rb") })
          @spinner.stop

          if response["error"]
            puts response["error"].inspect.brown
            @executing = false
            break
          end

          user_input = response["text"].to_s
          puts "USER> ".green + user_input
          @messages << { role: "user", content:user_input }
          print "ASSISTANT> ".magenta

          stop_stream = false
          reply = []

          keypresser = Thread.new do
            loop { stop_stream = true if $stdin.getch }
          end

          begin
            client.chat(
              parameters: {
                model: "gpt-3.5-turbo",
                messages: @messages,
                temperature: 0.7,
                stream: proc do |chunk, _bytesize|
                  break if stop_stream
                  message = chunk.dig("choices", 0, "delta", "content")
                  next if message.to_s.empty?

                  message = message.gsub("\n", "\r\n")

                  print message
                  reply += [message]
                end
              })
          rescue LocalJumpError
            puts
          ensure
            Thread.kill(keypresser)
            stop_stream = false
            @messages << { role: "assistant", content: reply.join }
            puts
          end

          audio_recorder.delete_audio_file
        end
      end

      def client
        @client ||= OpenAI::Client.new(access_token: AskChatGPT.access_token)
      end
    end

  end
end
