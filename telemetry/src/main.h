// the size of a serial payload
// this includes the command and any accompanying data for it
#define PAYLOAD_SIZE 8

// a generic serial payload
struct payload
{
    uint8_t type;  // the payload type
    uint8_t *data; // caution - this shouldn't exceed PAYLOAD_SIZE -1
};

enum operationMode
{
    STOPPED,
    RUNNING,
};

enum command
{
    GET_STATUS,  // get calibration status
    CHANGE_MODE, // change the operation mode
    START,       // start sending telemetry data
    STOP,        // stop sending telemetry data
};

enum payloadType
{
    INFORMATIONAL,
    TELEMETRY,
};

processCode processPayload(uint8_t *);