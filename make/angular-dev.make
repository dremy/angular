api = 2
core = 7.x

defaults[projects][subdir] = contrib

; Development Tool
projects[devel][version] = 1.5
projects[diff][version] = 3.2

; Code Quality
projects[coder][version] = 2.4

; Email Testing
projects[maillog][version] = 1.0-alpha1
; Behat step-definitions: https://drupal.org/node/1932698#comment-7131840
projects[maillog][patch][] = https://www.drupal.org/files/issues/behat-subcontext-1932698-7.patch

; User Simulation
projects[masquerade][version] = 1.0-rc7

; Demo Content
projects[uuid][download][branch] = 7.x-1.x
projects[uuid][download][revision] = a7bf2dbeb
projects[uuid_features][download][branch] = 7.x-1.x
projects[uuid_features][download][revision] = 1aa5baa9e0
