//
// defines the different types of messages
//
final int ASK_FOR_ENERGY = 0;
final int ASK_FOR_BULLETS = 1;
final int INFORM_ABOUT_FOOD = 2;
final int INFORM_ABOUT_TARGET = 3;
final int INFORM_ABOUT_XYTARGET = 4;

///////////////////////////////////////////////////////////////////////////
//
// Message
// =======
// > a message can be send by a robot to another robot
// > messages are caracterized by:
//   - type = basically "ask for something" or "inform about something" but
//     more types can be defined...
//   - agent = the sender of the message
//   - args = a list of arguments
//
///////////////////////////////////////////////////////////////////////////
class Message {
  int type;     // the type of the message
  int alice;    // transmitter
  int bob;      // receiver
  float[] args; // the arguments of the message
  
  //
  // constructor
  // ===========
  //
  Message(int ty, int transmitter, int receiver, float[] msgArgs) {
    type = ty;
    alice = transmitter;
    bob = receiver;
    args = new float[msgArgs.length];
    arrayCopy(msgArgs, args);
  }
}
