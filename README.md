# SyndiBox Text Engine
The SyndiBox Text Engine is a powerful dialog tool designed for use in RPGs and sidescrollers. It contains a tag system for denoting changes in color, speed, and position of text.

## Installing
You can download the latest version at the Release tab, or you can clone from the master branch and edit the engine yourself.

Once downloaded, unzip the `addons` folder to the root of your project.

You should now see `SyndiBox` as an option for your plugins under the `Plugins` tab of your `Project Settings`. Set the plugin to `Active` to use it in your project.

## Usage Guide
SyndiBox is meant to be an easy and stress-free way of implementing dialog into your Godot game projects. Here's an illustrated guide on the basics:

 1. Add a child Node to your Scene.![Add a child Node to your Scene.](https://imgur.com/4CxIqcX.png)
 2. Search for `SyndiBox` and click `Create`.![Search for "SyndiBox" and click "Create".](https://imgur.com/m3nZt1o.png)
 3. Position the Node to your preferred space on the screen.![Position your Node.](https://imgur.com/U22RfM3.png)
 4. Fill the properties in the Inspector with your dialog, auto advance, font, text voice, color, and text speed. You can use what is filled in the image below as an example.![Fill the Inspector properties.](https://imgur.com/0POjPSz.png)
 5. Press the `Play Scene` button (or `F6` on your keyboard) and watch it print!![There it is~](https://imgur.com/Fiigoty.png)

## Script Guide
Syndibox exposes some functions for use within GDScript that allow for dynamic control of the text and effects.   

`start(string: dialog, int: start_position)` - Resets, shows, and starts the dialog box, displaying the given string. Passing a string to start is functionally the same as entering the string as `Dialog` in the inspector.  
- **dialog** The string to display. A value of '' replays whatever the current Dialog set contains. Defaults to ''.  
- **start_position** Start position of the text. Defaults to 0.  

`stop(boolean: emit_signal)` - Resets and stops the dialog box. This method will optionally emit a signal 'text_finished' if you set emit_signal to true.  
- **emit_signal** Defaults to true.  

`manual_text_pause` - Boolean variable used to manually pause text processing. Defaults to false. Use `resume()` to resume normal processing (see below)  

`manual_text_hide` - Boolean variable used to manually hide text. Defaults to false. Use `resume()` to resume normal processing (see below)  

`resume(boolean: resume_Printing, boolean: show_Text, boolean: resume_Advancement)` - Resumes printing process that was manually paused or hidden   
- **resume_Printing** Defaults to true.  
- **show_Text** Shows Defaults to true.  
- **resume_Advancement** Defaults to true.  

## Text Effects
We can add special effect tags to make our text much prettier than a mock console gag. Something like this:![Very nice.](https://i.imgur.com/Q8c3tg3.gif)
(The second string was printed by typing "And [\`d]Hell[\*4]oooooooooo[\*r] Dolly~[\`r]")

## Full Effect List
#### Last Updated: v1.7.1

**Color**  
The color tag \[\` allows you to dynamically change the color, mid line.  
You can use hexadecimal HTML notation to assign color or you can use a predefiend shortcut code from the list below. (*Note*: Named colors or HSL will not work only hex codes) For example these are all valid color codes:
- ![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) `#f03c15` could be written as [\`f03c15\] or [\`#f03c15]
- ![#c5f015](https://via.placeholder.com/15/c5f015/000000?text=+) `#c5f015` could be written as [\`c5f015\] or  [\`#c5f015]
- ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `#1589F0` could be written as [\`1589F0] or [\`#1589F0]

[\`0] - Black  
[\`1] - Dark Blue  
[\`2] - Dark Green  
[\`3] - Dark Turquoise  
[\`4] - Dark Red  
[\`5] - Purple  
[\`6] - Gold  
[\`7] - Gray  
[\`8] - Dark Gray  
[\`9] - Blue  
[\`a] - Green  
[\`b] - Aqua  
[\`c] - Red  
[\`d] - Light Purple  
[\`e] - Yellow  
[\`f] - White  
[\`r] - Resets the color back to default  
[\`#] - Forces a line break without ending the line   

**Speed**  
The speed tag [\*x] (where x is the speed or shortcut code value) allows you to change the speed the text 'types' out on the screen.  
You can use '\*\*' to set a custom speed, lower the number the faster the text printing would be. For example, '[\*\*0.1]', '[\*\*1]', '[\*\*1e-3]' are all valid. You can also use the tags listed below for fast reference.

[\*1] - Fastest  
[\*2] - Fast  
[\*3] - "Normal" (i think its p slow tbh)  
[\*4] - Slow  
[\*5] - Slowest  
[\*i] - Start instant print  
[\*n] - End instant and return to default speed   

If you want all text to print out instantly, consider checking the 'Instant Text' option in the inspector.   

**Position**  
[\^t] - Tipsy  
[\^d] - Drunk  
[\^v] - Vibrate  
[\^r] - Resets the effect back to default

**Pause**  
[s#] - Pause for # seconds  
[t#] - Pause for # tenths of a second  

**Hide**  
[|#] - Hide for # seconds  
[:#] - Hide for # tenths of a second  

**Font**  
An unlimited amount of alternate fonts can be used and configured in the inspector. To swap between them use the font tag [%x], where x is the index of the font you want to switch to. For examples look at the list below    

[%0] - Switch to the 1st alternative font  
[%1] - Switch to the 2nd alternative font    
...    
[%99] - Switch to the 100th alternative font    
[%r] - Reset the font back to default  

**Signal**  
The signal tag allows you to send a signal with an `identifer` character in a Dialog string. This identifier can be any string of characters, and comes after the signal tag token `@`. For example `[@a]`, `[@12]`, `[@!#]` are all valid signal tags. The result is great flexibility in how your code interacts with your dialog letting you, for example, change the state of your world after you talk to someone, among many other possible scenarios. A very simple example of this in action is:  

- Given the following Dialog in a SyndiBox:  
`Time to test signals. [@test_signal]`

- And GDScript code similar to this:  
```gdscript
$SyndiBox.connect('signal_tag', self, '_on_SyndiBox_signal_tag')

func _on_SyndiBox_signal_tag(identifier):
     if identifier == 'real_signal':
         print('Path A')
     if identifier == 'test_signal':
         print('Path B')
```
    
- Activating the SyndiBox would result in the following printed to the console:  
`Path B`  

## Custom Tags
SyndiBox allows you to create your own custom tags without overwriting any of the main addon code. The token for custom tags can be anything you want. For example `[X!]` or `[Magenta]` or even `[ 2 1 ]` are all valid custom tags. The only thing tags need is to start with '[' and end with ']', it also must not be empty ([if you wish to test it out click here](regexr.com/5ei0l)). In order to create a custom tag you should do the following:  
- Find `custom.gd` in the addons folder  
- Optionally create your own copy of `custom.gd` (or name it anything else you want) outside of the addon folder, and set the `Custom Effects` variable in the inspector to this new file. This allows you to avoid overwriting your custom work when you upgrade this plugin.
- Add a new case to the match statement
- It is **critical** that you include `string.erase(sb.step,sb.emph.length())` and `string = string.insert(sb.step,char(8203))` if you do not wish to break encoding and nested tagging
- `sb` is the SyndiBox parent, and from there you can access any variables you wish to change, including but not limited to, `color`, `speed`, `font`, `timer`, and many more.

While the custom.gd has a couple good examples already, another simpler example is included below for reference:  
```gdscript
func check(string):
 match sb.emph:
  "[Magenta]": # Example
    string.erase(sb.step,sb.emph.length())
    string = string.insert(sb.step,char(8203))
    sb.color = Color(255, 0, 255, 1)
```  
This very simple example turns the text magenta when you use the tag `[Magenta]` in a Dialog string.  
As custom tags are checked and processed first, your custom tags will be overriden by any other tags in your dialog if they conflict. 

## Bugs/Issues
If you have any bugs/issues to report or features to request, please submit them to the Issues tab. If you need help and don't find your answer in the wiki's FAQ, Please contact me at Telegram (@sudospective) or Discord (Sudospective#0681) and I will reply at my earliest convenience.

## Donations
If you want to help support the development of SyndiBox, please consider donating! I get hungry sometimes and finding a job in the current global situation has proven to be a massive struggle (I'm still hopeful, though!), and every dollar counts. You can donate on PayPal over at https://paypal.me/sudospective. If PayPal gives you issues, I have a Ko-fi page over at https://ko-fi.com/sudospective. Thank you for the support!
