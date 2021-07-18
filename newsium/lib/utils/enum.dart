typedef ActionTypeCallback = void Function(ActionType actionType);
typedef AlertWidgetButtonActionCallback = void Function(int index);
typedef DateTimeSelectionCallback = void Function(DateTime dateTime);
typedef DatTimeMinPickerCallback = void Function(int day, int hours, int min);
typedef TimeMinPickerCallback = void Function(int hours, int min);
typedef NotificationOViewCallback = void Function(bool status);

enum ActionType {
  sendQuote,
  delete,
  chat,
  viewDetail,
}
