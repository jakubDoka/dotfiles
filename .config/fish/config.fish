if status is-interactive

    echo "$(cat ~/todos | tac)"


    export ANDROID_HOME=$HOME/Android/Sdk
    export ANDROID_SDK_ROOT=$ANDROID_HOME
    export NDK_HOME=$ANDROID_HOME/ndk/29.0.14033849

    set HEADPHONES_MAC "EE:36:62:B8:7A:43"
    set KEYBOARD_MAC   "ED:D9:36:92:D6:EC"
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

    function padd
        set -gx PATH $PATH $argv
    end
    padd $HOME/.cargo/bin
    padd $HOME/.detee/bin
    padd $ANDROID_HOME/cmdline-tools/latest/bin
    #padd $ANDROID_HOME/platform-tools
    padd $HOME/platform-tools/


    alias v='nvim'
    alias cpy='wl-copy'
    alias pst='wl-paste'
    alias dark='sudo sh -c "echo 50 > /sys/class/backlight/intel_backlight/brightness"'
    alias light='sudo sh -c "cat /sys/class/backlight/intel_backlight/max_brightness > /sys/class/backlight/intel_backlight/brightness"'
    alias headset="bluetoothctl connect $HEADPHONES_MAC"
    alias headunset="bluetoothctl disconnect $HEADPHONES_MAC"
    alias keyboardon="bluetoothctl connect $KEYBOARD_MAC"
    alias keyboardoff="bluetoothctl disconnect $KEYBOARD_MAC"
    alias hyperventilate='echo level disengaged | sudo tee /proc/acpi/ibm/fan'

    function restart-keyboard
        bluetoothctl remove "$KEYBOARD_MAC"
        bluetoothctl scan on
        sleep 5
        bluetoothctl pair "$KEYBOARD_MAC"
        bluetoothctl trust "$KEYBOARD_MAC"
    end

    ## config preservation
    alias gfg='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
    function gfgup
       gfg add $argv[1] && gfg commit -m"$argv[2]" && gfg push
    end
    function gfgupm
       gfg add -f -u && gfg commit -m"$argv[1]" && gfg push
    end

    function gacp
        git add $argv[1] && git commit -s && git push
    end

    function rgsed # global replace
      if [ "$argv[3]" = "-i" ]
        rg -l $argv[1] | xargs sed -i -E "s/$argv[1]/$argv[2]/g"
      else
        rg -l $argv[1] | xargs sed -E "s/$argv[1]/(& -> $argv[2])/g" | rg "\($argv[1] -> $argv[2]\)"
      end
    end

    # extra completions
    set COMP_DIR $HOME/.config/fish/completions/
    rg --generate=complete-fish > $COMP_DIR/rg.fish

    function sd # search directories
        set FZF_DEFAULT_COMMAND 'rg --files | rg -v "/target/"'
        set TARGET $(fzf --walker=dir,hidden)
        test -n "$TARGET" && cd $TARGET && __fish_cancel_commandline
    end

    function sf # search files
        set FZF_DEFAULT_COMMAND 'rg --files | rg -v "/target/"'
        set TARGET $(fzf --walker=file,hidden --preview="bat --color=always --style=header,grid --line-range :500 {}")
        test -n "$TARGET" && v $TARGET
    end

    function sa # search all
        set TARGET $(fzf --walker=file,dir,hidden)
        test -n "$TARGET" && v $TARGET
    end

    function perf-stamina
        sudo echo level disengaged | sudo tee /proc/acpi/ibm/fan
        sudo cpupower -c 0-7 frequency-set -u 2500mhz
        sudo cpupower -c 8-15 frequency-set -u 2000mhz
        sudo cpupower frequency-set -g performance
    end

    function perf-burst
        sudo echo level auto | sudo tee /proc/acpi/ibm/fan
        sudo cpupower -c 0-15 frequency-set -u 5000mhz
        sudo cpupower frequency-set -g performance
    end

    fnm env | source
end


function fish_user_key_bindings
    fish_vi_key_bindings
    fish_vi_cursor


    alias clear_kb='clear; commandline -f repaint'

    bind --mode insert \cE clear_kb
    bind --mode default \cE clear_kb
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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/mlokis/google-cloud-sdk/path.fish.inc' ]; . '/home/mlokis/google-cloud-sdk/path.fish.inc'; end
