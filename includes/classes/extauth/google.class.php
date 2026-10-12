<?php

/**
 *  2Moons
 *  Google OAuth2 external authentication
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */

class GoogleAuth implements externalAuth
{
	private $userData = NULL;

	public function __construct()
	{
	}

	public function isActiveMode()
	{
		return Config::get()->google_on == 1;
	}

	public function isValid()
	{
		if(!empty($this->userData))
		{
			return true;
		}

		if(!empty($_GET['error']))
		{
			HTTP::redirectTo('index.php');
		}

		if(empty($_GET['code']))
		{
			$this->redirectToGoogle();
		}

		$tokenData = $this->postRequest('https://oauth2.googleapis.com/token', array(
			'code'			=> $_GET['code'],
			'client_id'		=> Config::get()->google_clientid,
			'client_secret'	=> Config::get()->google_secret,
			'redirect_uri'	=> $this->getRedirectUri(),
			'grant_type'	=> 'authorization_code',
		));

		if(empty($tokenData['access_token']))
		{
			return false;
		}

		$userData = $this->getRequest('https://www.googleapis.com/oauth2/v3/userinfo', $tokenData['access_token']);

		if(empty($userData['sub']))
		{
			return false;
		}

		$this->userData = $userData;

		return true;
	}

	public function getAccount()
	{
		return empty($this->userData['sub']) ? 0 : $this->userData['sub'];
	}

	public function register()
	{
		return true;
	}

	public function getLoginData()
	{
		$sql = 'SELECT user.id, user.id_planet
		FROM %%USERS_AUTH%% auth
		INNER JOIN %%USERS%% user ON auth.id = user.id AND user.universe = :universe
		WHERE auth.account = :accountId AND auth.mode = :mode;';

		return Database::get()->selectSingle($sql, array(
			':mode'			=> 'google',
			':accountId'	=> $this->getAccount(),
			':universe'		=> Universe::current()
		));
	}

	public function getAccountData()
	{
		return array(
			'id'		=> $this->userData['sub'],
			'name'		=> isset($this->userData['name']) ? $this->userData['name'] : '',
			'email'		=> isset($this->userData['email']) ? $this->userData['email'] : '',
			'locale'	=> isset($this->userData['locale']) ? $this->userData['locale'] : '',
		);
	}

	private function getRedirectUri()
	{
		return HTTP_PATH.'index.php?page=externalAuth&method=google';
	}

	private function redirectToGoogle()
	{
		$params = http_build_query(array(
			'client_id'		=> Config::get()->google_clientid,
			'redirect_uri'	=> $this->getRedirectUri(),
			'response_type'	=> 'code',
			'scope'			=> 'openid email profile',
			'prompt'		=> 'select_account',
		));

		HTTP::sendHeader('Location', 'https://accounts.google.com/o/oauth2/v2/auth?'.$params);
		exit;
	}

	private function postRequest($url, $fields)
	{
		$curl = curl_init($url);
		curl_setopt_array($curl, array(
			CURLOPT_POST			=> true,
			CURLOPT_POSTFIELDS		=> http_build_query($fields),
			CURLOPT_RETURNTRANSFER	=> true,
			CURLOPT_TIMEOUT			=> 15,
			CURLOPT_CONNECTTIMEOUT	=> 10,
		));
		$response = curl_exec($curl);
		curl_close($curl);

		return empty($response) ? array() : (array) json_decode($response, true);
	}

	private function getRequest($url, $accessToken)
	{
		$curl = curl_init($url);
		curl_setopt_array($curl, array(
			CURLOPT_RETURNTRANSFER	=> true,
			CURLOPT_TIMEOUT			=> 15,
			CURLOPT_CONNECTTIMEOUT	=> 10,
			CURLOPT_HTTPHEADER		=> array('Authorization: Bearer '.$accessToken),
		));
		$response = curl_exec($curl);
		curl_close($curl);

		return empty($response) ? array() : (array) json_decode($response, true);
	}
}
