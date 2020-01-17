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

## Text Effects
We can add special effect tags to make our text much prettier than a mock console gag. Something like this:![Very nice.](https://i.imgur.com/Q8c3tg3.gif)
(The second string was printed by typing "And [\`d]Hell[\*4]oooooooooo[\*r] Dolly~[\`r]")

## Full Effect List
#### Last Updated: v1.5.0

**Color**  
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

**Speed**  
[\*1] - Fastest  
[\*2] - Fast  
[\*3] - "Normal" (i think its p slow tbh)  
[\*4] - Slow  
[\*5] - Slowest  

**Position**  
[\^t] - Tipsy  
[\^d] - Drunk  
[\^v] - Vibrate  

**Pause**  
[s#] - Pause for # seconds  
[t#] - Pause for # tenths of a second  

**Hide**  
[|#] - Hide for # seconds  
[:#] - Hide for # tenths of a second  


## Bugs/Issues
If you have any bugs/issues to report, please submit them to the Issues tab. If you'd like to submit a feature and need help, Please contact me at Telegram (@sudospective) or Discord (Sudospective#0681) and I will reply at my earliest convenience.
