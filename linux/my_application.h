#ifndef FLUTTER_my_new_food_appLICATION_H_
#define FLUTTER_my_new_food_appLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, my_new_food_application, MY, APPLICATION,
                     GtkApplication)

/**
 * my_new_food_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* my_new_food_application_new();

#endif  // FLUTTER_my_new_food_appLICATION_H_
