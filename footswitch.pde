/*
 * Copyright (c) 2012 Kyle Delaney
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
 
#define LED_PIN 11
#define SWITCH_PIN 0
#define BUZZER_PIN 22

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
    tone(BUZZER_PIN, 4000, 250);
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
            //beep at the end of each hold limit so that the user knows which action will be taken
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
                case 1: //switch between up and down
                    reverse = !reverse;
                    break;
                case 2: //lock the PC (Windows keyboard shortcut)
                    Keyboard.set_modifier(MODIFIERKEY_GUI);
                    Keyboard.send_now();
                    Keyboard.set_key1(KEY_L); //Keyboard.set_key1(KEY_ESC);
                    Keyboard.send_now();
                    Keyboard.set_key1(0);
                    Keyboard.send_now(); 
                    Keyboard.set_modifier(0);
                    Keyboard.send_now();
                    break;
                default: //send up or down
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
