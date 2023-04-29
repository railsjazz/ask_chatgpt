- 0.3.0
  - added CLI tool:
    Example:
    - `ask_chatgpt -q "how to unzip file with Ruby"`
    - `ask_chatgpt -f path/file.json -q "extract emails from JSON"`
  - added streaming option (default), can be configured in initializer `config.mode`
  - disable markdown for results `config.markdown = false`
  - renamed config option `included_prompt` to `included_prompts` (breaking change, but very easy to fix)
  - a little bit tuned prompts to reply with Markdown

- 0.2.1
  - customizable prompts
  - documentation, examples

- 0.1, 0.2
  - MVP
