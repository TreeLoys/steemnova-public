{block name="title" prepend}{$LNG.siteTitleIndex}{/block}
{block name="content"}
<section>
	<h1>{$descHeader}</h1>
	<p class="desc">{$descText}</p>
	<p class="desc"><ul id="desc_list">{foreach $gameInformations as $info}<li>{$info}</li>{/foreach}</ul></p>
</section>
<section>
	<div class="contentbox">
		
				<h1>{$LNG.loginHeader}</h1>
				<form id="login" name="login" action="index.php?page=login" data-action="index.php?page=login" method="post">
					<div class="row">
						<select name="uni" id="universe" class="changeAction">{html_options options=$universeSelect selected=$UNI}</select>
						<input name="username" id="username" type="text" placeholder="{$LNG.loginUsername}">
						<input name="password" id="password" type="password" placeholder="{$LNG.loginPassword}">
						{if $verkey["capaktiv"]==1}
							<script src='https://www.google.com/recaptcha/api.js'></script>
							<script>function onSubmit() { document.getElementById("login").submit(); } </script>
							<input class="g-recaptcha" data-sitekey="{$verkey["cappublic"]}" data-callback="onSubmit" type="submit" value="{$LNG.loginButton}">
						{else}
							<input type="submit" value="{$LNG.loginButton}">
						{/if}

					</div>
				</form>
				{if $facebookEnable}<a href="#" data-href="index.php?page=externalAuth&method=facebook" class="fb_login"><img src="styles/resource/images/facebook/fb-connect-large.png" alt=""></a>{/if}
				{if $googleEnable}<button type="button" class="google-btn" onclick="window.location='index.php?page=externalAuth&amp;method=google'"><svg viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>{$LNG.loginGoogle}</button>{/if}
								
				<a href="/index.php?page=register"><input value="{$LNG.buttonRegister}"></a>
				<!-- <br><span class="small">{$loginInfo}</span> -->
			
	</div>
</section>
<section>
<!-- 	<div class="button-box">
		<div class="button-box-inner">
			<div class="button-important">
				<a href="index.php?page=register">
					<span class="button-left"></span>
					<span class="button-center">{$LNG.buttonRegister}</span>
					<span class="button-right"></span>
				</a>
			</div>
		</div>
	</div>
	<div class="button-box">
		<div class="button-box-inner">
			{if $mailEnable} 
			<div class="button multi">
				<a href="index.php?page=lostPassword">
					<span class="button-left"></span>
					<span class="button-center">{$LNG.buttonLostPassword}</span>
					<span class="button-right"></span>
				</a>
			</div>
			<div class="button multi">
			{else}
			<div class="button">
			{/if}
				<a href="index.php?page=screens">
					<span class="button-left"></span>
					<span class="button-center">{$LNG.buttonScreenshot}</span>
					<span class="button-right"></span>
				</a>
			</div>
		</div>
	</div> -->
</section>
{/block}
{block name="script" append}
<script>{if $code}alert({$code|json});{/if}</script>
{/block}