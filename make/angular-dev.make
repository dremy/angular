api = 2
core = 7.x

defaults[projects][subdir] = contrib

; Development Tool
projects[devel][version] = 1.5
projects[diff][version] = 3.2

; Code Quality 
; Unable to download coder-7.x-2.4.tar.gz
; projects[coder][version] = 2.4

; Email Testing
projects[maillog][version] = 1.0-alpha1
; Behat step-definitions: https://drupal.org/node/1932698#comment-7131840
projects[maillog][patch][] = https://www.drupal.org/files/issues/behat-subcontext-1932698-7.patch

; User Simulation
projects[masquerade][version] = 1.0-rc7