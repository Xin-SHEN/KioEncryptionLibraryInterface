package
{

import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.symmetric.ICipher;

import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

import mx.core.ByteArrayAsset;

public class EncryptionFactory extends EventDispatcher   
{
	//this is the CircleCalculator library.swf file (encrypted with LibraryEncrypter of course)
	[Embed (source="libraryForEncryption.swf", mimeType="application/octet-stream")]
	private var encryptedSwf:Class;
	
	private var _circleCalculator:IXinSpirit=null;
	
	public function EncryptionFactory(completeHandler:Function)
	{
		super();
		this.addEventListener(Event.COMPLETE, completeHandler);
		
		//load up the swf file that contains the CircleCalculator class
		var fileData:ByteArrayAsset = ByteArrayAsset(new encryptedSwf());
		
		var key:ByteArray = new ByteArray();
		fileData.readBytes(key, 0, 8);
		var encryptedBytes:ByteArray = new ByteArray();
		fileData.readBytes(encryptedBytes);
		
		//解密library.swf
		var aes:ICipher = Crypto.getCipher("blowfish-ecb", key, Crypto.getPad("pkcs5"));
		aes.decrypt(encryptedBytes);
		
		//将该SWF装载到目前的域
		var ldr:Loader = new Loader();
		var ldrContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		
		//对AIR的支持
		if(ldrContext.hasOwnProperty("allowLoadBytesCodeExecution"))
			ldrContext.allowLoadBytesCodeExecution = true;
		
		ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
		ldr.loadBytes(encryptedBytes, ldrContext);
	}
	
	private function loadSwfComplete(event:Event):void
	{
		var cc:Class = ApplicationDomain.currentDomain.getDefinition("XinSpirit") as Class;
		_circleCalculator = new cc();
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	/**
	 * @return an object implementing the ICircleCalculator interface
	 */
	public function getInstance():IXinSpirit
	{
		return _circleCalculator;
	}
}
}