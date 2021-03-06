import '../../app_credentials.dart' as Credentials;

// Redirect URI of the microsoft app
const String MICROSOFT_OAUTH_REDIRECT_URI = Credentials.MICROSOFT_OAUTH_REDIRECT_URI;
// Microsoft application id
const String MICROSOFT_AZURE_APP_ID = Credentials.MICROSOFT_AZURE_APP_ID;

// Server REST URL
const String SERVER_REST_URL = Credentials.SERVER_REST_URL;

// REST services endpoints
const String REST_SERVICE_PATH_LOGIN_EMPLOYEE = "/loginEmployees";
const String REST_SERVICE_PATH_GET_EMPLOYEE_ID_FROM_THE_USER_MAIL = "/getEmployeeIdFromTheUserMail";
const String REST_SERVICE_PATH_INSERT_CONTROL_HOURS = "/insertControlHours";
const String REST_SERVICE_PATH_START_TIMING = "/startTiming";
const String REST_SERVICE_PATH_STOP_TIMING = "/stopTiming";

// Entities
const String ENTITY_EMPLOYEE_PRESENCE_CONTROL_HOURS = "EMobLAEmpleadosPresenceControlHours";
const String ENTITY_EMPLOYEE_PRESENCE_CONTROL_MONTH_HOURS = "EMobLAEmpleadosPresenceControlMonthHours";
