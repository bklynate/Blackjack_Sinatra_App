$(document).ready(function() {
	player_hits();
	player_stays();
	dealer_hit();
});

function player_hits() {
	$(document).on('click', '#hit_button input', function() {
	  $.ajax({
			type: 'POST',
			url: '/hit'
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});
}

function player_stays() {
	$(document).on('click', '#stay_button input', function() {
	  $.ajax({
			type: 'POST',
			url: '/stay'
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});
}

function dealer_hit() {
	$(document).on('click', '#dealer_hit input', function() {
		$.ajax({
			type: 'POST',
			url: '/dealer_hit'
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});
}
