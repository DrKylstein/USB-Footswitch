const int LED_PIN = 11;
const int SWITCH_PIN = 0;

int8_t switchNow;
int8_t switchPrevious = LOW;

boolean switchHeld = false;
boolean reverse = false;

long time = 0;
long time_held = 0;
uint8_t funcLevel = 0;

const long DEBOUNCE = 50;
const long MODESWITCH_TIME = 1000;
const long LOCK_TIME = 3000;

void beep() {
    tone(22, 4000, 250);
}

void setup() {
    pinMode(SWITCH_PIN, INPUT);
    digitalWrite(SWITCH_PIN, HIGH);

    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);
}
void loop() {
    //debounce
    switchNow = digitalRead(SWITCH_PIN);
    if(switchNow != switchPrevious) {
        time = millis();
    }
    if((millis() - time) > DEBOUNCE) {
        if(switchNow == LOW) {
            // record that the switch is pressed, and for how long
            if(!switchHeld) {
            switchHeld = true;
            }
            time_held = millis() - time;
            if(time_held > MODESWITCH_TIME && funcLevel == 0) {
                ++funcLevel;
                beep();
            } else if(time_held > LOCK_TIME && funcLevel == 1) {
                ++funcLevel;
                beep();
            }
        } else if(switchNow == HIGH && switchHeld) {
            //now that the switch is released, take action
            switchHeld = false;
            switch(funcLevel) {
                case 1:
                    reverse = !reverse;
                    break;
                case 2:
                    Keyboard.set_modifier(MODIFIERKEY_GUI);
                    Keyboard.send_now();
                    Keyboard.set_key1(KEY_L); //Keyboard.set_key1(KEY_ESC);
                    Keyboard.send_now();
                    Keyboard.set_key1(0);
                    Keyboard.send_now(); 
                    Keyboard.set_modifier(0);
                    Keyboard.send_now();
                    break;
                default:
                    if(reverse) {
                    Keyboard.set_key1(KEY_UP);
                    } else {
                    Keyboard.set_key1(KEY_DOWN);
                    }
                    Keyboard.send_now();
                    delay(50);
                    Keyboard.set_key1(0);
                    Keyboard.send_now();
            }
            funcLevel = 0;
        }
    }
    switchPrevious = switchNow;
}
