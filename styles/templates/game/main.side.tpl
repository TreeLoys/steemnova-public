<div class="fold">
	<a class="btn" href="#" onclick="toggleAside()">
		<i class="fas fa-angle-double-right"></i>
	</a>
</div>

<script>
function toggleAside() {
    $('aside').css('display', 'none');
	$('content').css('grid-column', '3/5');
	$('content').css('max-width', 'unset');
}
</script>
