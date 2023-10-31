

__vsim ()   #  By convention, the function name
{                 #+ starts with an underscore.
  local cur
  local prev
  local prev2
  local cmd
  local wordlist
  local wordlist2
  local name
  local file
  local var

  #some args of interest
  local _vsim=0
  local _file=0
  local _var=0
  local _oldarg
  local _oldval
  local _dotline=".                                                                                "

  COMPREPLY=()   # Array variable storing the possible completions.

  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}
  cmd=${COMP_WORDS[1]}

  # No command yet so list them out
  if [ $COMP_CWORD -eq 1 ];then
    case "$cur" in
      *) COMPREPLY=( $( compgen -W 'console create delete deploy export help image import modify mount options \
                                    poweroff printenv printvmx rename run show start stop suspend \
                                    setenv setvmx unmount unsetenv unsetvmx update ' -- $cur ) );;
    esac
    return 0
  fi

  # Accept abbreviation in place of a command
  #Command abbreviations are nice to have
  commandlist="console\ncreate\ndelete\nexport\ndeploy\nhelp\nimport\nmodify\nmount\noptions\npoweroff\nprintenv\nprintvmx\nrename\nrun\nsetenv\nsetvmx\nshow\nsoftware\nstart\nstop\nsuspend\nunmount\nunsetenv\nunsetvmx\nupdate\n"
  matchcount=$(printf $commandlist | grep ^$cmd | wc -l | tr -ds " " " ")
  if [ "$matchcount" = 1 ];then cmd=$(printf $commandlist | grep ^$cmd);fi

  # Find some of the key variables
  # even if they are positional
  case $cmd in
      # For these commands a positional value in position 2 is the vsim name
      console | create | delete | deploy | export | image | make | modify | mount | poweroff | kill | printenv | printvmx \
      | rename | run  | setenv | setvmx| show | start | stop | suspend | unmount | unsetenv | unsetvmx | update )
        if ! [[ "${COMP_WORDS[2]}" == -* ]] && [ -n "${COMP_WORDS[2]}" ]; then _vsim=1;name="${COMP_WORDS[2]}";fi
      ;;
      import )
        if ! [[ "${COMP_WORDS[2]}" == -* ]] && [ -n "${COMP_WORDS[2]}" ]; then _file=1;file="${COMP_WORDS[2]}";fi
      ;;
  esac


  # Collect data from the $COMP_LINE
  count=1
  for i in ${COMP_WORDS[@]}; do

    arg=${COMP_WORDS[count-1]}
    argv=${COMP_WORDS[count]}
    [[ "$argv" == -* ]] && argv=""

    # flip the switch when a arg is seen
    case $i in 
      -vsim ) _vsim=1;;
      -file ) _file=1;;
      -variable ) _var=1;;
    esac

    # capture values if present
    case $arg in
      -vsim ) name=$argv;;
      -file ) file=$argv;;
      -variable ) var=$argv;;
    esac

    count=$((++count))
  done

  # Build list of unused args by command
  case $cmd in 
    console | mount | poweroff | stop | suspend | unmount ) 
      ((_vsim)) || wordlist="$wordlist -vsim"
      ;;
    create )
      # Mandatory 
      ((_vsim)) || wordlist="$wordlist -vsim"
      #! [[ "$COMP_LINE" == *"-vsim"* ]] && [ -z "$name" ] && wordlist="$wordlist -vsim"
      ! [[ "$COMP_LINE" == *"-version"* ]] && ! [[ "$COMP_LINE" == *"-package"* ]] && wordlist="$wordlist -version -package"
     # ! [[ "$COMP_LINE" == *"-version"* ]] && ! [[ "$COMP_LINE" == *"-package"* ]] && wordlist="$wordlist -package"
      # Optional
      ! [[ "$COMP_LINE" == *"-mode"* ]] && wordlist2="$wordlist2 -mode"
      ! [[ "$COMP_LINE" == *"-partner"* ]] && wordlist2="$wordlist2 -partner"
      if ! [[ "$COMP_LINE" == *"-auto"* ]] && ! [[ "$COMP_LINE" == *"-create"* ]] && ! [[ "$COMP_LINE" == *"-join"* ]]; then wordlist2="$wordlist2 -auto -create -join";fi 
      ! [[ "$COMP_LINE" == *"-serial"* ]] && wordlist2="$wordlist2 -serial" 
      ! [[ "$COMP_LINE" == *"-memsize"* ]] && wordlist2="$wordlist2 -memsize"         
      ! [[ "$COMP_LINE" == *"-nics"* ]] && wordlist2="$wordlist2 -nics" 
      ! [[ "$COMP_LINE" == *"-nat"* ]] && wordlist2="$wordlist2 -nat"
      ! [[ "$COMP_LINE" == *"-hostonly"* ]] && wordlist2="$wordlist2 -hostonly"
      ! [[ "$COMP_LINE" == *"-bridged"* ]] && wordlist2="$wordlist2 -bridged"
      ! [[ "$COMP_LINE" == *"-vnvram"* ]] && wordlist2="$wordlist2 -vnvram"
      ! [[ "$COMP_LINE" == *"-vnvsize"* ]] && wordlist2="$wordlist2 -vnvsize"
      ! [[ "$COMP_LINE" == *"-vdevinit"* ]] && wordlist2="$wordlist2 -vdevinit"
      ! [[ "$COMP_LINE" == *"-vidconsole"* ]] && ! [[ "$COMP_LINE" == *"-comconsole"* ]]  &&  wordlist2="$wordlist2 -vidconsole -comconsole" 
      #! [[ "$COMP_LINE" == *"-create"* ]]  && ! [[ "$COMP_LINE" == *"-join"* ]] && wordlist2="$wordlist2 -create -join"
      ;;
    delete )
      ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-fod"* ]]  &&  wordlist="$wordlist -vsim -fod"   
      ;;
    deploy )
      ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-fod"* ]]  &&  wordlist="$wordlist -vsim -fod"  
      ! [[ "$COMP_LINE" == *"-host"* ]] && wordlist="$wordlist -host"
      ! [[ "$COMP_LINE" == *"-datastore"* ]] && wordlist="$wordlist -datastore"
      ! [[ "$COMP_LINE" == *"-nat"* ]] && wordlist2="$wordlist2 -nat"
      ! [[ "$COMP_LINE" == *"-hostonly"* ]] && wordlist2="$wordlist2 -hostonly" 
      ;;
    export ) 
      # This one is required
      ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-fod"* ]]  &&  wordlist="$wordlist -vsim -fod" 
      # These are discretionary
      ! [[ "$COMP_LINE" == *"-tgz"* ]] && wordlist2="$wordlist2 -tgz" 
      if ((_vsim));then 
        ! [[ "$COMP_LINE" == *"-ova"* ]] && wordlist2="$wordlist2 -ova"    
        ! [[ "$COMP_LINE" == *"-vbox"* ]] && wordlist2="$wordlist2 -vbox" 
        ! [[ "$COMP_LINE" == *"-image"* ]] && wordlist2="$wordlist2 -image" 
#        ! [[ "$COMP_LINE" == *"-image1"* ]] && wordlist2="$wordlist2 -image1"     
#        ! [[ "$COMP_LINE" == *"-image2"* ]] && wordlist2="$wordlist2 -image2" 
      fi;;
    help ) wordlist='console create delete export help image import modify mount options \
                     poweroff printenv printvmx rename run show start stop suspend \
                     setenv setvmx unmount unsetenv unsetvmx update usage '
      ;;
    import )
      if ! ((_file)) && ! [[ "$COMP_LINE" == *"-package"* ]]; then wordlist="$wordlist -file -package";fi   
      if ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-package"* ]];  then wordlist2="$wordlist2 -vsim";fi   
      ;;
    modify )
      if ! ((_vsim));then wordlist="$wordlist -vsim";fi
      ! [[ "$COMP_LINE" == *"-serial"* ]] && wordlist2="$wordlist2 -serial" 
      ! [[ "$COMP_LINE" == *"-memsize"* ]] && wordlist2="$wordlist2 -memsize" 
      ! [[ "$COMP_LINE" == *"-nat"* ]] && wordlist2="$wordlist2 -nat"
      ! [[ "$COMP_LINE" == *"-hostonly"* ]] && wordlist2="$wordlist2 -hostonly"
      ! [[ "$COMP_LINE" == *"-bridged"* ]] && wordlist2="$wordlist2 -bridged"
      ! [[ "$COMP_LINE" == *"-nics"* ]] && wordlist2="$wordlist2 -nics" 
      ! [[ "$COMP_LINE" == *"-vnvram"* ]] && wordlist2="$wordlist2 -vnvram"
      ! [[ "$COMP_LINE" == *"-vnvsize"* ]] && wordlist2="$wordlist2 -vnvsize"
      ! [[ "$COMP_LINE" == *"-vdevinit"* ]] && wordlist2="$wordlist2 -vdevinit"
      ! [[ "$COMP_LINE" == *"-vidconsole"* ]] && ! [[ "$COMP_LINE" == *"-comconsole"* ]]  &&  wordlist2="$wordlist2 -vidconsole -comconsole"        
      ;;  
    printenv | printvmx | unsetenv | unsetvmx ) 
      ! ((_vsim)) && wordlist="$wordlist -vsim"
      ! ((_var)) && wordlist2="$wordlist2 -variable"
      ;;
    rename  ) 
      ! ((_vsim)) && wordlist="$wordlist -vsim"
      ! [[ "$COMP_LINE" == *"-newname"* ]] && wordlist="$wordlist -newname"
      ;;
    run )    
      ! ((_vsim)) && wordlist="$wordlist -vsim"
      ! [[ "$COMP_LINE" == *"-password"* ]] && wordlist2="$wordlist2 -password"               
      ! [[ "$COMP_LINE" == *"-command"* ]] && ! [[ "$COMP_LINE" == *"-script"* ]] && wordlist2="$wordlist2 -command -script"
      ;;
    setenv | setvmx  ) 
      ! ((_vsim)) && wordlist="$wordlist -vsim"
      ! ((_var)) && wordlist="$wordlist -variable"
      ! [[ "$COMP_LINE" == *"-value"* ]] && wordlist="$wordlist -value"
      ;;
    show ) 
      ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-package"* ]] && wordlist2="$wordlist2 -vsim -package"
      ;;
    start ) 
      ! ((_vsim)) && wordlist="$wordlist -vsim"
      ! [[ "$COMP_LINE" == *"-gui"* ]] && wordlist2="$wordlist2 -gui"
      ;;
    image )
      # round 1
      if ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-package"* ]] && ! [[ "$COMP_LINE" == *"-version"* ]] && ! [[ "$COMP_LINE" == *"-list"* ]]; then wordlist="$wordlist -vsim -list";fi
      if ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-package"* ]] && ! [[ "$COMP_LINE" == *"-version"* ]]; then wordlist2="$wordlist2 -package -version";fi
      if ! ((_vsim)) && ! [[ "$COMP_LINE" == *"-list"* ]]; then wordlist="$wordlist -list";fi
      # round 2 -vsim
      if ((_vsim));then 
#          ! [[ "$COMP_LINE" == *"-image1"* ]] && ! [[ "$COMP_LINE" == *"-image2"* ]] && wordlist2="$wordlist2 -image1 -image2" 
          ! [[ "$COMP_LINE" == *"-image"* ]] && wordlist="$wordlist -image"     
          ! [[ "$COMP_LINE" == *"-isdefault"* ]] && wordlist="$wordlist -isdefault true"
      fi
      ;;  
    update )
      if ! ((_vsim));then wordlist="$wordlist -vsim";fi
      ! [[ "$COMP_LINE" == *"-version"* ]] && ! [[ "$COMP_LINE" == *"-package"* ]] && wordlist="$wordlist -version"
      ! [[ "$COMP_LINE" == *"-version"* ]] && ! [[ "$COMP_LINE" == *"-package"* ]] && wordlist="$wordlist -package"
      ! [[ "$COMP_LINE" == *"-image"* ]] && wordlist2="$wordlist2 -image" 
#      ! [[ "$COMP_LINE" == *"-image1"* ]] && wordlist2="$wordlist2 -image1"     
#      ! [[ "$COMP_LINE" == *"-image2"* ]] && wordlist2="$wordlist2 -image2"    
      ! [[ "$COMP_LINE" == *"-isdefault"* ]] && wordlist2="$wordlist2 -isdefault"      
      ;;        
  esac

  COMPREPLY=( $( compgen -W "$wordlist" -- $cur ) )

  # Special cases for positional args
  case "$prev" in
      # For cases were the first arg is positional for <vsim name> use -vsim completion
      console | create | delete | deploy | export | image | make | modify | mount | poweroff | kill | printenv | printvmx \
      | rename | run  | setenv | setvmx| show | start | stop | suspend | unmount | unsetenv | unsetvmx | update )
          if [ -n "$cur" ] && [[ "$cur" != -* ]];then prev="-vsim";fi;;
      import )
          if [ -n "$cur" ] && [[ "$cur" != -* ]];then prev="-file";fi;;  
  esac

  # Hint at the values expected for these arguments
  if [ -z "$cur" ] || [[ "$cur" == *'?'* ]];then
    case "$prev" in
      -bridged )
            COMPREPLY=( "  {<netport>, ... }           Network Ports                                      " "$_dotline" );;
      -create | -join | -cluster )
            COMPREPLY=( "  <text>                      Cluter Name                                        " "$_dotline" );;
      -command )
            COMPREPLY=( "  <text>                      Command to Run                                     " "$_dotline" );;
      -datastore )
            COMPREPLY=( "  <text>                      ESXi Datastore                                     " "$_dotline" );;
      -file | -script | -simdir ) 
            COMPREPLY=( $( compgen -A file -- "$cur" ) );return 0;;
      -fod | -fa | -fb )
            COMPREPLY=( "  <text>                      Failover Directory Name                            " "$_dotline" )
            case $cmd in delete ) 
            COMPREPLY=( $( compgen -W "$(vsim show -listfod)" -- $cur ) );;esac;;
      -host )
            COMPREPLY=( "  <host name | ip>            ESXi Host                                          " "$_dotline" );;
      -hostonly )
            COMPREPLY=( "  {<netport>, ... }           Network Ports                                      " "$_dotline" )
            case $cmd in deploy )
            COMPREPLY=( "  <portgroup>                 ESXi Cluster Network (Cluster Network)             " "$_dotline" );;esac;;
      -image ) 
            COMPREPLY=( "  image1                      Image1                                             "
                        "  image2                      Image2                                             " "$_dotline" );;
      -isdefault )
            COMPREPLY=( $( compgen -W "true" -- $cur )) 
            if [[ "$cur" == *'?'* ]];then
            COMPREPLY=( "  {true|false}                Is Default Image                                   " "$_dotline" );fi;;
      -memsize ) 
            COMPREPLY=( "  {<integer> (1600..8192)}    Memory size in MB                                  " "$_dotline" );;
      -mode ) 
            COMPREPLY=( "  { 7 | C }                   Data ONTAP Operating Mode                          " "$_dotline" );;
      -nat )
            COMPREPLY=( "  {<netport>, ... }           Network Ports                                      " "$_dotline" )
            case $cmd in deploy )
            COMPREPLY=( "  <portgroup>                 ESXi Data Network (VM Network)                     " "$_dotline" );;esac;;
      -nics )
            COMPREPLY=( "  {<integer> (4..10)}         Number of network interfaces                       " "$_dotline" );;  
      -package ) 
            COMPREPLY=( $( compgen -W "$(vsim image -listpackages)" -- "$cur" ) )
            if [[ "$cur" == *'?'* ]];then            
            COMPREPLY=( "  <image.tgz>                 Data ONTAP software package                        " "$_dotline" );fi;;
      -partner | -newname )
            COMPREPLY=( "  <vsim name>                 Vsim Name                                          " "$_dotline" );;
      -serial )
            COMPREPLY=( "  <serial number>             System Serial Number                               " "$_dotline" );;
      -value )
            COMPREPLY=( "  <text>                      Variable Value                                     " "$_dotline" )
            case $cmd in setenv )
            COMPREPLY=( $( compgen -W "$(vsim printenv -vsim "$name" -variable "$var" -quick)" -- "$cur" ) );;esac;;
      -variable )
            COMPREPLY=( "  <text>                      Variable Name                                      " "$_dotline" )
            if [[ "$cur" != *'?'* ]];then case $cmd in 
              printenv | setenv | unsetenv )  
                COMPREPLY=( $( compgen -W "$(vsim printenv -vsim "$name" -quick -list)" -- "$cur" ) );;
              printvmx | setvmx | unsetvmx )  
                COMPREPLY=( $( compgen -W "$(vsim printvmx -vsim "$name" -quick -list)" -- "$cur" ) );;esac;fi;;
      -version )
            COMPREPLY=( "  <text>                      Data ONTAP software version                        " "$_dotline" )
            COMPREPLY=( $( compgen -W "$(vsim image -listversions)" -- $cur ) );;   
      -vnvram ) 
            COMPREPLY=( "  <fake|full|partner|panic>   Virtual NVRAM Mode                                 " "$_dotline" );;
      -vnvsize )
            COMPREPLY=( "  {<integer> (32..256)}       Virtual NVRAM size in MB                           " "$_dotline" );;
      -vsim )
            COMPREPLY=( $( compgen -W "$(vsim show -list)" -- $cur ) ) 
            case $cmd in create | import )
            COMPREPLY=( "  <vsim name>                 Vsim name                                          " "$_dotline" );;esac
            if [[ "$cur" == *'?'* ]];then
            COMPREPLY=( "  <vsim name>                 Vsim name                                          " "$_dotline" );fi;;
      *  ) # Otherwise feed the next word from the list
          case "$cmd" in export | help | import | show ) ;; #do nothing, otherwise:
          * ) COMPREPLY=( $( compgen -W "$(echo "$wordlist" | cut -d' ' -f2)" -- $cur ) ) ;;
          esac
          # If we are out of required args offer up optionals
          if [ "X$wordlist" = "X" ];then
            COMPREPLY=( $( compgen -W "$wordlist2" -- $cur ) );fi
          ;;
    esac
  else 
    case "$prev" in
      -fod ) 
          COMPREPLY=( $( compgen -W "$(vsim show -listfod)" -- $cur ) );;
      -file | -script ) 
          COMPREPLY=( $( compgen -A file -- $cur ) );return 0;;
      -image )
          COMPREPLY=( $( compgen -W "image1 image2" -- $cur ) );;
      -simdir )
          OLDIFS=$IFS
          IFS=$'\n' 
          COMPREPLY=( $( compgen -A file -- $cur ) )
          IFS=$OLDIFS
          return 0;;
      -mode ) 
          COMPREPLY=( $( compgen -W "C 7" -- $cur));;
      -package )
          COMPREPLY=( $( compgen -W "$(vsim image -listpackages)" -- "$cur" ) $( compgen -A file -- $cur ) );;
      -isdefault )
          COMPREPLY=( $( compgen -W "true false" -- $cur ) );;
      -value )
          case $cmd in setenv )
          COMPREPLY=( $( compgen -W "$(vsim printenv -vsim "$name" -variable "$var" -quick)" -- "$cur" ) );;esac;;
      -variable )
          case $cmd in 
            printenv | setenv | unsetenv )  
              COMPREPLY=( $( compgen -W "$(vsim printenv -vsim "$name" -quick -list)" -- "$cur" ) );;
            printvmx | setvmx | unsetvmx )  
              COMPREPLY=( $( compgen -W "$(vsim printvmx -vsim "$name" -quick -list)" -- "$cur" ) );;
          esac;;
      -version ) 
          COMPREPLY=( $( compgen -W "$(vsim image -listversions)" -- $cur ) );;
      -vnvram ) 
          COMPREPLY=( $( compgen -W "fake full partner panic" -- $cur ));;
      -vsim )
          case $cmd in create | import ) ;; # Don't tab complete
          *) COMPREPLY=( $( compgen -W "$(vsim show -list)" -- $cur ) );;
          esac;;
      *  ) # Otherwise feed the next word from the list
          case "$cmd" in export | help | image | import | show ) ;; #do nothing, otherwise:
          * ) # COMPREPLY=( $( compgen -W "$(echo "$wordlist" | cut -d' ' -f2)" -- $cur ) ) ;;
              COMPREPLY=( $( compgen -W "$wordlist $wordlist2" -- "$cur" ) );;
          esac
          # If we are out of required args offer up optionals
          if [ "X$wordlist" = "X" ];then
            COMPREPLY=( $( compgen -W "$wordlist2" -- $cur ) );fi
          ;;
    esac
  fi

  if [[ "$cur" == *'?'* ]];then
      #This is hokey
      # but gives the illusion of working if the PS1 is not too complex
      prompt=$(printf PS1=\""$PS1"\" | bash -i 2>&1 | tail -n 1 | sed 's/exit$//')
      printf "\n$COMPREPLY\n\n"
      printf "$prompt$COMP_LINE"
      COMPREPLY=( )
  fi

  # Modify has special needs
  if [ "$cmd" = "modify" ];then
    case "$prev" in
      -bridged | -hostonly | -memsize | -nat | -nics | -serial | -vnvsize | -vnvram  )
            _oldarg=$(echo "$prev" | cut -d'-' -f2)
            _oldval="$(vsim show -vsim "$name" -quick | grep "$_oldarg" | cut -d':' -f2 | tr -d "[:space:]" )"
            if [ -n "$_oldval" ] && [ "$cur" != '?' ]; then COMPREPLY=( $( compgen -W "$_oldval" -- $cur ) );fi;;
    esac
  fi

  return 0
}

complete -F __vsim -o filenames ./vsim
complete -F __vsim -o filenames vsim
