api = 2
core = 7.x

defaults[projects][subdir] = contrib

; Features
projects[features][version] = 2.4
projects[features][patch][] = https://www.drupal.org/files/issues/features-catch_field_exceptions-1664160-26.patch
projects[features_override][version] = 2.0-rc2
projects[ctools][version] = 1.7
projects[features_extra][version] = 1.0-beta1
projects[strongarm][version] = 2.0

; Views
projects[views][version] = 3.10
; Fixes Page Creation AJAX Error on Nginx
projecst[views][patch][] = https://www.drupal.org/files/issues/views-ajax-nginx-1036962-71.patch

;
; Form & Field API
;
projects[field_group][version] = 1.4
projects[elements][version] = 1.4
projects[email][version] = 1.3
; Add email verification field
projects[email][patch][] = https://www.drupal.org/files/issues/email-verification_field-234682-8.patch
projects[link][version] = 1.3
projects[telephone][version] = 1.0-alpha1
projects[name][version] = 1.9
projects[field_collection] = 1.0-beta8
projects[field_collection_table][version] = 1.0-beta2

;
; Improved Site Management
;
projects[admin_menu][version] = 3.0-rc5
projects[module_filter][version] = 2.0
projects[admin_views][version] = 1.4
projects[views_bulk_operations][version] = 3.2
projects[views_data_export][version] = 3.0-beta8
