#!/bin/bash 

function kungfu() {
    BLUE_BOLD='\033[1;34m'
    NC='\033[0m' # No Color

    if [ "$1" = "nsp" ]; then
        kctrl app kick -a provisioner -n tap-namespace-provisioning -y
        kctrl package installed kick -i namespace-provisioner -n tap-install -y
    elif [ "$1" = "tap" ]; then
        kctrl package installed kick -i "$1" -n tap-install -y
    elif [ "$1" = "package" ]; then
        if [ -z "$2" ]; then
            echo "Usage: kungfu package <package-name>"
        else
            kctrl package installed kick -i "$2" -n tap-install -y
        fi
    elif [ "$1" = "sync" ]; then
        kctrl app kick -a sync -n tanzu-sync -y
    elif [ "$1" = "post-install" ]; then
        kctrl app kick -a tap-post-install-gitops -n tap-install -y
    elif [ "$1" = "install" ]; then
        kctrl app kick -a tap-install-gitops -n tap-install -y
    elif [ "$1" = "chop" ]; then
        kctrl app kick -a sync -n tanzu-sync -y
        kctrl package installed kick -i tap -n tap-install -y
        kctrl app kick -a tap -n tap-install -y
        kctrl app kick -a tap-post-install-gitops -n tap-install -y
        kctrl app kick -a provisioner -n tap-namespace-provisioning -y
    elif [ "$1" = "help" ]; then
        echo " "
        echo -e "${BLUE_BOLD}Available kungfu commands:${NC}"
        echo "  kungfu tap                     - Run kctrl package installed kick -i tap -n tap-install -y"
        echo "  kungfu nsp                     - Run kctrl app kick -a provisioner -n tap-namespace-provisioning"
        echo "  kungfu package <package-name>  - Run kctrl package installed kick -i <package> -n tap-install"
        echo "  kungfu sync                    - Run kctrl app kick -a sync -n tanzu-sync"
        echo "  kungfu install                 - Run kctrl app kick -a tap-install-gitops -n tap-install"
        echo "  kungfu post-install            - Run kctrl app kick -a tap-post-install-gitops -n tap-install"
        echo "  kungfu chop                    - Kicks the sync app, tap package, tap app, and post install and NSP apps to reconcile all change"
    else
        echo "Unknown command: $1"
        echo "Use 'kungfu help' to see all available commands."
    fi
}

kungfu $1