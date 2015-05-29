api = 2
core = 7.x

defaults[projects][subdir] = contrib

;
; Basic Modules
;
projects[entity][version] = 1.6
projects[libraries][version] = 2.2
projects[ctools][version] = 1.7

; Features
projects[features][version] = 2.4
projects[features][patch][] = https://www.drupal.org/files/issues/features-catch_field_exceptions-1664160-26.patch
projects[features_override][version] = 2.0-rc2
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

; Time
projects[date][version] = 2.8
projects[date][patch][2294973] = https://www.drupal.org/files/issues/date-title_date_formats-2294973-70.patch
projects[date][patch][2449261] = https://www.drupal.org/files/issues/date-cannot_create_references_to_from_string_offsets-2449261-1.patch
projects[date_restrictions][version] = 1.x-dev
projects[date_restrictions][revision] = c6dc62f

;
; Improved Site Management
;
projects[admin_menu][version] = 3.0-rc5
projects[module_filter][version] = 2.0
projects[admin_views][version] = 1.4
projects[views_bulk_operations][version] = 3.2
projects[views_data_export][version] = 3.0-beta8


;
; Libraries
;

; Profiler
libraries[profiler][download][type] = get
libraries[profiler][download][url] = http://ftp.drupal.org/files/projects/profiler-7.x-2.0-beta2.tar.gz
