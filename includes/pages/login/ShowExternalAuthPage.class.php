<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */

class ShowExternalAuthPage extends AbstractLoginPage
{
	public static $requireModule = 0;

	function __construct() 
	{
		parent::__construct();
	}
	
	function show() 
	{
		$method			= HTTP::_GP('method', '');
		$method			= strtolower(str_replace(array('_', '\\', '/', '.', "\0"), '', $method));
		$path			= 'includes/classes/extauth/'.$method.'.class.php';
		
		if(!file_exists($path)) {
			HTTP::redirectTo('index.php');			
		}

		$session	= Session::create();

		require 'includes/classes/extauth/externalAuth.interface.php';
		require $path;
		
		$methodClass	= ucwords($method).'Auth';

		/** @var $authObj externalAuth */
		$authObj		= new $methodClass;
		
		if(!$authObj->isActiveMode())
		{
			$session->delete();
			$this->redirectTo('index.php?code=5');
		}
		
		if(!$authObj->isValid())
		{
			$session->delete();
			$this->redirectTo('index.php?code=4');
		}
		
		$loginData	= $authObj->getLoginData();

		if(empty($loginData))
		{
			// hand the verified account to the registration form via a
			// short-lived HMAC-signed cookie; the GET param alone is spoofable
			// and anonymous sessions do not survive this class' shutdown.
			// config.php only defines $salt inside the including scope.
			$salt = (function() { require 'includes/config.php'; return isset($salt) ? $salt : ''; })();
			// url-safe base64 without '=' padding: PHP cookie parsing
			// would otherwise split the value on the padding characters
			// hand email/name along so the registration form can be prefilled
			$accountData	= $authObj->getAccountData();
			$payload	= rtrim(strtr(base64_encode(json_encode(array(
				'a'	=> (string) $authObj->getAccount(),
				'm'	=> $method,
				'e'	=> TIMESTAMP + 900,
				'em'	=> isset($accountData['email']) ? $accountData['email'] : '',
				'nm'	=> isset($accountData['name']) ? $accountData['name'] : '',
			))), '+/', '-_'), '=');
			$signature	= hash_hmac('sha256', $payload, $salt);
			setcookie('extauth', $payload.'.'.$signature, array(
				'expires'	=> TIMESTAMP + 900,
				'path'		=> '/',
				'secure'	=> true,
				'httponly'	=> true,
				'samesite'	=> 'Lax',
			));

			$session->delete();
			$this->redirectTo('index.php?page=register&externalAuth[account]='.$authObj->getAccount().'&externalAuth[method]='.$method);
		}

		$session->userId		= (int) $loginData['id'];
		$session->adminAccess	= 0;
		$session->save();
		$this->redirectTo("game.php");	
	}
}