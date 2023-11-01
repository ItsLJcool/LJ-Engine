//
package backend
import discord_rpc.DiscordRpc;
import Sys;

class Discord {
    public static var clientID(get, set):String = "1169090901470085140";
    public static var backup_clientID:String = "1169090901470085140"; // used in case the clientID is null or isn't a real ID.
    public static var init:Bool = false;
    
	static private function get_clientID() return clientID;

	static private function set_clientID(set:String) {
        if (set == null) return;
		return clientID = Std.string(set);
	}

	public static function switchRPC(clientID:String) {
		if (Discord.clientID != (Discord.clientID = clientID)) {
			DiscordRpc.shutdown();
			DiscordRpc.start({
				clientID: Discord.clientID,
				onReady: onReady,
				onError: onError,
				onDisconnected: onDisconnected
			});
		}
	}

    override function new () {
        super();
        DiscordRpc.start({
			clientID: clientID,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true) {
			DiscordRpc.process();
			Sys.sleep(2);
		}

		DiscordRpc.shutdown();
    }

	public static function shutdown() {
        trace("Closing Discord RPC");
		DiscordRpc.shutdown();
	}

    public static function initialize() {
        if (init) return trace("Discord RPC already initalized!");
        sys.thread.Thread.create(() -> {
            new Discord();
        });
    }

    static function onReady() {
        init = true;
        DiscordRpc.presence({
            details: "Starting Up...",
            largeImageKey: 'ljengine_alt',
            largeImageText: "Friday Night Funkin' - LJ Engine",
        });
    }

    static function onError(_code:Int, _message:String) {
        trace('Error! $_code | $_message');
    }

    static function onDisconnected(_code:Int, _message:String) {
        trace('Disconnected! $_code | $_message');
    }
    
    public static function changePresence(state:String, details:String, smallImageKey:String, ?timestamp:Bool = false, endTimeStamp:Int) {
        var startTimestamp:Float = if (timestamp) Date.now().getTime() else 0;

		if (endTimeStamp > 0) endTimeStamp = startTimestamp + endTimeStamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'ljengine_alt',
			largeImageText: "Friday Night Funkin' - LJ Engine",
			smallImageKey : smallImageKey,
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimeStamp / 1000),
		});
    }
    /**
        Basically a Typedef that allows you to input a customize everything.
        @param state [String] - Top Text (bold, a bit bigger)
        @param details [String] - Below state, not bolded and in the middle of the large icon.
        @param startTimestamp [Int] - basically if you do `Date.now().getTime()`, endTimestamp will handle the rest. Usually a countdown timer but can also show how long you have been playing. Use miliseconds because code will divide by 1000.
        @param endTimestamp [Int] - `Date.now().getTime() + (5*1000)`, this will count 5 seconds to 0. Use miliseconds because code will divide by 1000.
        @param largeImageKey [String] - Discord's Bot API Rich Presence image. Currently only `ljengnie_alt, ljengine` work. Also ALL MUST BE LOWERCASE.
        @param largeImageText [String] - Text when hovering above the Large image.
        @param smallImageKey [String] - Discord's Bot API Rich Presence image. Currently only `ljengnie_alt, ljengine` work. Also ALL MUST BE LOWERCASE.
        @param smallImageText [String] - Text when hovering above the Small image.
    **/
    public static function customPresence(status:Dynamic) {
        if (status.startTimestamp != null) status.startTimestamp = Std.int(status.startTimestamp / 1000);
        if (status.endTimestamp != null) status.endTimestamp = Std.int(status.endTimestamp / 1000);
        if (status.largeImageKey != null) status.largeImageKey = status.largeImageKey.toLowerCase();
        if (status.largeImageText != null) status.largeImageText = status.largeImageText.replace("{lenny}", "( ͡° ͜ʖ ͡°)");
        if (status.smallImageText != null) status.smallImageText = status.smallImageText.replace("{lenny}", "( ͡° ͜ʖ ͡°)");

        DiscordRpc.presence(status);
    }
}
/**
    @:optional var state   : String;
    @:optional var details : String;
    @:optional var startTimestamp : Int;
    @:optional var endTimestamp   : Int;
    @:optional var largeImageKey  : String;
    @:optional var largeImageText : String;
    @:optional var smallImageKey  : String;
    @:optional var smallImageText : String;
    @:optional var partyID   : String;
    @:optional var partySize : Int;
    @:optional var partyMax  : Int;
    @:optional var matchSecret    : String;
    @:optional var spectateSecret : String;
    @:optional var joinSecret     : String;
    @:optional var instance : Int;
    @:optional var button1Label:String;
    @:optional var button1Url:String;
    @:optional var button2Label:String;
    @:optional var button2Url:String;
**/