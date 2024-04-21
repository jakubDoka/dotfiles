if status is-interactive
    set HEADPHONES_MAC "EE:36:62:B8:7A:43"

    function padd
        set -gx PATH $PATH $argv
    end
    padd $HOME/.cargo/bin

    alias v='nvim'
    alias cpy='wl-copy'
    alias pst='wl-paste'
    alias dark='sudo sh -c "echo 50 > /sys/class/backlight/intel_backlight/brightness"'
    alias light='sudo sh -c "cat /sys/class/backlight/intel_backlight/max_brightness > /sys/class/backlight/intel_backlight/brightness"'
    alias headset="bluetoothctl connect $HEADPHONES_MAC"
    alias headunset="bluetoothctl disconnect $HEADPHONES_MAC"

    ## config preservation
    alias gfg='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
    function gfgup
       gfg add -f $argv[1] && gfg commit -m"$argv[2]" && gfg push
    end
    function gfgupm
       gfg add -f -u && gfg commit -m"$argv[1]" && gfg push
    end

    function gacp
        git add $argv[1] && git commit -m"$argv[2]" && git push
    end

    ## global replace
    function rgsed
      if "$argv[3]" = "-i"
        rg -l $argv[1] | xargs sed -i -E "s/$argv[1]/$argv[2]/g"
      else
        rg -l $argv[1] | xargs sed -E "s/$argv[1]/(& -> $argv[2])/g" | rg "\($argv[1] -> $argv[2]\)"
      end
    end

    # extra completions
    set COMP_DIR $HOME/.config/fish/completions/
    rg --generate=complete-fish > $COMP_DIR/rg.fish
end


function fish_user_key_bindings
    fish_vi_key_bindings
    fish_vi_cursor

    function sarch_directories
        set FZF_DEFAULT_COMMAND 'rg --files'
        set TARGET $(fzf --walker=dir,follow,hidden)
        test -n "$TARGET" && cd $TARGET && __fish_cancel_commandline
    end

    function sarch_files
        set FZF_DEFAULT_COMMAND 'rg --files'
        set TARGET $(fzf --walker=file,follow,hidden)
        test -n "$TARGET" && v $TARGET
    end

    function sarch_all
        set TARGET $(fzf --walker=file,follow,hidden)
        test -n "$TARGET" && v $TARGET
    end

    bind --mode default \x20sd sarch_directories
    bind --mode default \x20sf sarch_files
    bind --mode default \x20sa sarch_all
end

function fish_prompt
    set STATUS $status
    echo -n "::<"
    set_color C46A00
    echo -n "$(prompt_pwd)"
    if [ $STATUS -ne 0 ]
        set_color normal
        echo -n ", "
        set_color red
        echo -n "$STATUS"
    end
    set_color normal
    echo -n '> '
end

function fish_greeting

end
