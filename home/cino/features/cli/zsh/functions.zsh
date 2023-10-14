# Enable compatibility with bash's completion system
autoload -U bashcompinit && bashcompinit

# Make sure meta-delete is bash-style
autoload -U select-word-style && select-word-style bash
