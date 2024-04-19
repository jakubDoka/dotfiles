if status is-interactive
    # Commands to run in interactive sessions can go here

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

    ## git
    function gacm
        git add -u && git commit -m"$argv[1]" && git push
    end

    ## global replace
    function rgsed
      if "$argv[3]" = "-i"
        rg -l $argv[1] | xargs sed -i -E "s/$argv[1]/$argv[2]/g"
      else
        rg -l $argv[1] | xargs sed -E "s/$argv[1]/(& -> $argv[2])/g" | rg "\($argv[1] -> $argv[2]\)"
      end
    end
end

function fish_prompt
    set_color C46A00
    echo -n " $(prompt_pwd)"
    set_color normal
    echo -n ' > '
end

function fish_greeting

end
