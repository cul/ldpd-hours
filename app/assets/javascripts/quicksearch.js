// Strip potentially destructive character sequences from an HTML string
CUL.escapeHtml = function(html) {
    return html
    	.replace(/javascript\:/g, '')
		.replace(/&/g, '&amp;')
		.replace(/\</g, '&lt;')
		.replace(/\>/g, '&gt;')
		.replace(/"/g, '&quot;')
		.replace(/'/g, '&#039;');
}

$(document).ready(function(){
    var bestBetsUrl = "https://key-resources.library.columbia.edu/key_resources.json?context=BestBets";

    var bestBetResultTemplate = function(bestBetsResult) {
        return 	'<div class="best-bet-result">' +
            		'<strong>' + CUL.escapeHtml(bestBetsResult.title) + '</strong>' +
            		(bestBetsResult.description.length == 0 ? '' : ' - ' + CUL.escapeHtml(bestBetsResult.description)) +
                    //'<br />' + '<a href="' + bestBetsResult.url + '"> + bestBetsResult.url + '</a>' +
                    '<br />' +
                    '<a href="' + bestBetsResult.url + '">' + bestBetsResult.url + '</a>' +
            	'</div>';
    };

    var dataObjectTokenizer = function(dataObject) {
		return Bloodhound.tokenizers.whitespace(dataObject.haystack);
    };

    var queryTokenizer = function(query) {
		return Bloodhound.tokenizers.whitespace(query);
    };

    $.ajax({
        url: bestBetsUrl,
        type: 'GET',
        cache: false
    }).done(function(bestBetsDataset) {
        // Expected format of each array item in bestBetsDataset
        // {
		// 	   description: "Avery Index to Architectural Periodicals",
        //     haystack: "Avery Index Avery Index to Architectural Periodicals Avery",
        //     id: 5,
        //     keywords: "Avery",
        //     tags: "BestBets",
        //     title: "Avery Index",
        //     tokens: "Avery",
        //     url: "http://library.columbia.edu/locations/avery/avery-index.html"
        // }

        var bloodhoundSearchEngine = new Bloodhound({
          local: bestBetsDataset,
          datumTokenizer: dataObjectTokenizer,
          queryTokenizer: queryTokenizer
        });

        $('#quicksearch').typeahead({
            hint: false,
            highlight: false,
            minLength: 3
        }, {
			name: 'best_bets',
			source: bloodhoundSearchEngine,
            templates: {
                suggestion: function (data) { return bestBetResultTemplate(data); }
            },
            limit: 5,
        	display: 'title' // only put the title field in the search input
		});

        // Make hero search form visible by removing invisible class
        $('#hero-search-form').removeClass('invisible');

    }).fail(function (jqXHR, status, error) {
        console.error("Unable to retrieve Bets Bets results for Quicksearch");
    });

	// When keying up and down through best bet suggestions, enter key press will send the user to the selected item url
    $('#quicksearch').on('keydown', function(e) {
        // Note: event.code is the right way to do things going forward, but isn't compatible with all browsers, so we'll use fallbacks like "which" and "keyCode".
        var isEnterKey = (event.code && event.code === 'Enter') || (e.which && e.which === 13) || (e.keyCode && e.keyCode === 13);
        var $selectedBestBetResult = $(this).closest('form').find('.best-bet-result.tt-cursor');
        if(isEnterKey && $selectedBestBetResult.length > 0) {
            // Prevent default so form isn't submitted
            e.preventDefault();
            // Navigate to selected best bet item url
	        window.location.href = $selectedBestBetResult.find('a').attr('href');
            return;
        }
    });

    // Clicking on a best bet suggestion, send the user to the selected item url
    $('#hero-search').on('click', '.best-bet-result', function(e) {
        // Prevent default so that a click on an anchor tag is ignored in favor of the javascript below
        e.preventDefault();
        // Navigate to clicked-on best bet item url
        window.location.href = $(this).find('a').attr('href');
        return;
    });
});
