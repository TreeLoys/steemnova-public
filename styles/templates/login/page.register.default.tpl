{block name="title" prepend}{$LNG.siteTitleRegister}{/block}
{block name="content"}
<div id="registerFormWrapper">
<form id="registerForm" method="post" action="index.php?page=register" data-action="index.php?page=register">
<input type="hidden" value="send" name="mode">
<input type="hidden" value="{$externalAuth.account}" name="externalAuth[account]">
<input type="hidden" value="{$externalAuth.method}" name="externalAuth[method]">
<input type="hidden" value="{$referralData.id}" name="referralID">
	<div class="rowForm">
		<label for="universe">{$LNG.universe}</label>
		<select name="uni" id="universe" class="changeAction">{html_options options=$universeSelect selected=$UNI}</select>
		{if !empty($error.uni)}<span class="error errorUni"></span>{/if}
	</div>
	{if !empty($externalAuth.account)}
	{if $facebookEnable}
	<div class="rowForm">
		<label>{$LNG.registerFacebookAccount}</label>
		<span class="text fbname">{$accountName}</span>
	</div>
	{/if}
	{if $googleEnable && $externalAuth.method == 'google'}
	<div class="rowForm">
		<label>{$LNG.loginGoogle}</label>
		<span class="text" style="display:inline-block;margin:7px 0 7px;vertical-align:middle;">{$LNG.registerGoogleBound}</span>
		<div class="clear"></div>
	</div>
	{/if}
	{elseif empty($referralData.id)}
	{if $googleEnable}
	<div class="rowForm">
		<label>{$LNG.loginGoogle}</label>
		<button type="button" class="google-btn" onclick="window.location='index.php?page=externalAuth&amp;method=google'"><svg viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>{$LNG.loginGoogleButton}</button>
		<div class="clear"></div>
	</div>
	{/if}
	{/if}
	<div class="rowForm">
		<label for="username">{$LNG.registerUsername}</label>
		<input type="text" class="input" name="username" id="username" maxlenght="32" value="{$extUsername}">
		{if !empty($error.username)}<span class="error errorUsername"></span>{/if}
		<span class="inputDesc">{$LNG.registerUsernameDesc}</span>
	</div>
	{if $extVerified}
	<div class="rowForm">
		<label>{$LNG.registerEmail}</label>
		<span class="text" style="display:inline-block;margin:7px 0;vertical-align:middle;">{$extEmail} — {$LNG.registerGoogleEmailNote}</span>
		<div class="clear"></div>
	</div>
	<div class="rowForm">
		<label>{$LNG.registerPassword}</label>
		<span class="text" style="display:inline-block;margin:7px 0;vertical-align:middle;">{$LNG.registerGooglePassNote}</span>
		<div class="clear"></div>
	</div>
	{else}
	<div class="rowForm">
		<label for="password">{$LNG.registerPassword}</label>
		<input type="password" class="input" name="password" id="password">
		{if !empty($error.password)}<span class="error errorPassword"></span>{/if}
		<span class="inputDesc">{$registerPasswordDesc}</span>
	</div>
	<div class="rowForm">
		<label for="passwordReplay">{$LNG.registerPasswordReplay}</label>
		<input type="password" class="input" name="passwordReplay" id="passwordReplay">
		{if !empty($error.passwordReplay)}<span class="error errorPasswordReplay"></span>{/if}
		<span class="inputDesc">{$LNG.registerPasswordReplayDesc}</span>
	</div>
	<div class="rowForm">
		<label for="email">{$LNG.registerEmail}</label>
		<input type="email" class="input" name="email" id="email">
		{if !empty($error.email)}<span class="error errorEmail"></span>{/if}
		<span class="inputDesc">{$LNG.registerEmailDesc}</span>
	</div>
	<div class="rowForm">
		<label for="emailReplay">{$LNG.registerEmailReplay}</label>
		<input type="email" class="input" name="emailReplay" id="emailReplay">
		{if !empty($error.emailReplay)}<span class="error errorEmailReplay"></span>{/if}
		<span class="inputDesc">{$LNG.registerEmailReplayDesc}</span>
	</div>
	{/if}
	{if count($languages) > 1}
	<div class="rowForm">
		<label for="language">{$LNG.registerLanguage}</label>
		<select name="lang" id="language">{html_options options=$languages selected=$lang}</select>
		{if !empty($error.language)}<span class="error errorLanguage"></span>{/if}
		<div class="clear"></div>
	</div>
	{/if}
	{if !empty($referralData.name)}
	<div class="rowForm">
		<label for="language">{$LNG.registerReferral}</label>
		<span class="text">{$referralData.name}</span>
		{if !empty($error.language)}<span class="error errorLanguage"></span>{/if}
		<div class="clear"></div>
	</div>
	{/if}
	{if $recaptchaEnable && !$extVerified}
	<div class="rowForm" id="captchaRow">
		<label>{$LNG.registerCaptcha}</label>
		<div class="g-recaptcha" data-sitekey="{$recaptchaPublicKey}"></div>
		<div class="clear"></div>
	</div>
	{/if}
	<div class="rowForm">
		<label for="rules">{$LNG.registerRules}</label>
		<input type="checkbox" name="rules" id="rules" value="1" checked>
		{if !empty($error.rules)}<span class="error errorRules"></span>{/if}
		<span class="inputDesc">{$registerRulesDesc}</span>
	</div>
	<div class="rowForm">
		<input type="submit" class="submitButton" value="{$LNG.buttonRegister}">
	</div>
</form>
{/block}
{block name="script" append}
<link rel="stylesheet" type="text/css" href="styles/resource/css/login/register.css?v={$REV}">
{if $recaptchaEnable && !$extVerified}
<script type="text/javascript" src="https://www.google.com/recaptcha/api.js?hl={$lang}"></script>
{/if}
<script type="text/javascript" src="scripts/login/register.js"></script>
{/block}