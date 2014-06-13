# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

class TwitterCldr.SegmentationParser
	constructor : ->
		@begin_token ||= new TwitterCldr.Token "special_char", "\\A"
		@regex_parser ||= new TwitterCldr.UnicodeRegexParser

	class Rule
		constructor : ->

	class BreakRule extends Rule
		constructor : (@left, @right) ->
			super

		@boundary_symbol = "break"		

		@match : (str) ->
			left_match = str.match(left)

			if @left? && left_match?
				match_pos = str.indexOf(left_match[0]) + left_match[0].length

				if @right?
					right_match = str.slice(match_pos).match(right)
					
					result = {}					
					
					if right_match?
						result[string] = left_match[0] + right_match [0]
						result[id] = match_pos

					else
						result[string] = str
						result[id] = str.length

					result
			
			return null

	class NoBreakRule extends Rule
		constructor : (@regex) ->
			super

		@boundary_symbol = no_break

		@match : (str) ->
			match = str.match(regex)
			{ string : match[0], id : str.indexOf(match[0]) + match[0].length } if match?
				

	@do_parse: (options = {}) ->
		regex_token_lists = []
		current_regex_tokens = []
		boundary_symbol = null

		while current_token()?
			switch current_token()
				when "break", "no_break"
					boundary_symbol = current_token.type
					regex_token_lists.push(current_regex_tokens)
					current_regex_tokens = []
				else
					current_regex_tokens.push(current_token())

			next_token(current_token().type)

		regex_token_lists.push(current_regex_tokens)

		result = null

		switch boundary_symbol
			when "break"
				result = new BreakRule parse_regex(add_anchors(regex_token_lists[0]), options), parse_regex(add_anchors(regex_token_lists[1]), options)
			when "no_break"
				result = new NoBreakRule parse_regex(add_anchors([].concat(regex_token_lists...)), options)
		
		result

	@add_anchors : (token_list) ->
		token_list.splice (0, 0, @begin_token)

	@parse_regex : (tokens, options = {}) ->
		if tokens? and tokens.length != 0 then new TwitterCldr.UnicodeRegex @regex_parser.parse(tokens), options else null
