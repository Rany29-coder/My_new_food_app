#include "my_new_food_application.h"

int main(int argc, char** argv) {
  g_autoptr(MyApplication) app = my_new_food_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
