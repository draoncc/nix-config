# Sessions will append history file instead of replacing it
setopt APPEND_HISTORY
# Treat #, ~ and ^ as part of patterns for filename generation
setopt EXTENDED_GLOB

# No beeping!
unsetopt BEEP
# Don't print error when pattern for filename generation has no matches
unsetopt NOMATCH
