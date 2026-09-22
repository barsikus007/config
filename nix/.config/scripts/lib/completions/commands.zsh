#? capture-term takes any command line, so offer every callable name
compadd -- ${(k)commands} ${(k)aliases} ${(k)functions} ${(k)builtins}
