
# line 1 "./lib/liquid/parser.rl"
=begin
      LITERALS = {
        nil => nil, 'nil' => nil, 'null' => nil, '' => nil,
        'true'  => true,
        'false' => false,
        'blank' => :blank?,
        'empty' => :empty?
      }

      def resolve(key)
        if LITERALS.key?(key)
          LITERALS[key]
        else
          case key
          when /^'(.*)'$/ # Single quoted strings
            $1
          when /^"(.*)"$/ # Double quoted strings
            $1
          when /^(-?\d+)$/ # Integer and floats
            $1.to_i
          when /^\((\S+)\.\.(\S+)\)$/ # Ranges
            (resolve($1).to_i..resolve($2).to_i)
          when /^(-?\d[\d\.]+)$/ # Floats
            $1.to_f
          else
            variable(key)
          end
        end
      end
=end

# line 91 "./lib/liquid/parser.rl"

# % fix syntax highlighting


module Liquid
  module Parser
    
# line 43 "./lib/liquid/parser.rb"
class << self
	attr_accessor :_fsm_actions
	private :_fsm_actions, :_fsm_actions=
end
self._fsm_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6, 1, 
	7, 1, 8, 1, 9
]

class << self
	attr_accessor :_fsm_key_offsets
	private :_fsm_key_offsets, :_fsm_key_offsets=
end
self._fsm_key_offsets = [
	0, 0, 15, 16, 17, 30, 31, 33, 
	35, 45, 46, 48, 50, 60, 62, 65, 
	68, 81, 81, 83, 87, 89, 92, 100, 
	109, 118, 127, 136, 144, 154, 163, 171, 
	180, 189, 198, 207, 215, 218, 219, 227, 
	236, 245, 254, 263, 271, 281, 290, 298, 
	307, 316, 325, 334, 342, 344, 346, 359, 
	360, 362, 363, 365, 367, 371, 373, 376, 
	384, 393, 402, 411, 420, 428, 438, 447, 
	455, 464, 473, 482, 491, 499, 500, 501, 
	501, 504, 506, 513, 514, 515, 515, 523, 
	531, 539, 547, 554, 563, 571, 578, 586, 
	594, 602, 610
]

class << self
	attr_accessor :_fsm_trans_keys
	private :_fsm_trans_keys, :_fsm_trans_keys=
end
self._fsm_trans_keys = [
	34, 39, 40, 43, 45, 91, 102, 110, 
	116, 48, 57, 65, 90, 97, 122, 34, 
	39, 34, 39, 43, 45, 102, 110, 116, 
	48, 57, 65, 90, 97, 122, 34, 34, 
	46, 34, 46, 34, 39, 43, 45, 48, 
	57, 65, 90, 97, 122, 39, 39, 46, 
	39, 46, 34, 39, 43, 45, 48, 57, 
	65, 90, 97, 122, 48, 57, 46, 48, 
	57, 46, 48, 57, 34, 39, 43, 45, 
	102, 110, 116, 48, 57, 65, 90, 97, 
	122, 48, 57, 41, 46, 48, 57, 48, 
	57, 41, 48, 57, 41, 95, 48, 57, 
	65, 90, 97, 122, 41, 95, 97, 48, 
	57, 65, 90, 98, 122, 41, 95, 108, 
	48, 57, 65, 90, 97, 122, 41, 95, 
	115, 48, 57, 65, 90, 97, 122, 41, 
	95, 101, 48, 57, 65, 90, 97, 122, 
	41, 95, 48, 57, 65, 90, 97, 122, 
	41, 95, 105, 117, 48, 57, 65, 90, 
	97, 122, 41, 95, 108, 48, 57, 65, 
	90, 97, 122, 41, 95, 48, 57, 65, 
	90, 97, 122, 41, 95, 108, 48, 57, 
	65, 90, 97, 122, 41, 95, 114, 48, 
	57, 65, 90, 97, 122, 41, 95, 117, 
	48, 57, 65, 90, 97, 122, 41, 95, 
	101, 48, 57, 65, 90, 97, 122, 41, 
	95, 48, 57, 65, 90, 97, 122, 46, 
	48, 57, 46, 46, 95, 48, 57, 65, 
	90, 97, 122, 46, 95, 97, 48, 57, 
	65, 90, 98, 122, 46, 95, 108, 48, 
	57, 65, 90, 97, 122, 46, 95, 115, 
	48, 57, 65, 90, 97, 122, 46, 95, 
	101, 48, 57, 65, 90, 97, 122, 46, 
	95, 48, 57, 65, 90, 97, 122, 46, 
	95, 105, 117, 48, 57, 65, 90, 97, 
	122, 46, 95, 108, 48, 57, 65, 90, 
	97, 122, 46, 95, 48, 57, 65, 90, 
	97, 122, 46, 95, 108, 48, 57, 65, 
	90, 97, 122, 46, 95, 114, 48, 57, 
	65, 90, 97, 122, 46, 95, 117, 48, 
	57, 65, 90, 97, 122, 46, 95, 101, 
	48, 57, 65, 90, 97, 122, 46, 95, 
	48, 57, 65, 90, 97, 122, 48, 57, 
	48, 57, 34, 39, 43, 45, 102, 110, 
	116, 48, 57, 65, 90, 97, 122, 34, 
	34, 93, 39, 39, 93, 48, 57, 46, 
	93, 48, 57, 48, 57, 93, 48, 57, 
	93, 95, 48, 57, 65, 90, 97, 122, 
	93, 95, 97, 48, 57, 65, 90, 98, 
	122, 93, 95, 108, 48, 57, 65, 90, 
	97, 122, 93, 95, 115, 48, 57, 65, 
	90, 97, 122, 93, 95, 101, 48, 57, 
	65, 90, 97, 122, 93, 95, 48, 57, 
	65, 90, 97, 122, 93, 95, 105, 117, 
	48, 57, 65, 90, 97, 122, 93, 95, 
	108, 48, 57, 65, 90, 97, 122, 93, 
	95, 48, 57, 65, 90, 97, 122, 93, 
	95, 108, 48, 57, 65, 90, 97, 122, 
	93, 95, 114, 48, 57, 65, 90, 97, 
	122, 93, 95, 117, 48, 57, 65, 90, 
	97, 122, 93, 95, 101, 48, 57, 65, 
	90, 97, 122, 93, 95, 48, 57, 65, 
	90, 97, 122, 34, 39, 46, 48, 57, 
	48, 57, 95, 48, 57, 65, 90, 97, 
	122, 34, 39, 95, 97, 48, 57, 65, 
	90, 98, 122, 95, 108, 48, 57, 65, 
	90, 97, 122, 95, 115, 48, 57, 65, 
	90, 97, 122, 95, 101, 48, 57, 65, 
	90, 97, 122, 95, 48, 57, 65, 90, 
	97, 122, 95, 105, 117, 48, 57, 65, 
	90, 97, 122, 95, 108, 48, 57, 65, 
	90, 97, 122, 95, 48, 57, 65, 90, 
	97, 122, 95, 108, 48, 57, 65, 90, 
	97, 122, 95, 114, 48, 57, 65, 90, 
	97, 122, 95, 117, 48, 57, 65, 90, 
	97, 122, 95, 101, 48, 57, 65, 90, 
	97, 122, 95, 48, 57, 65, 90, 97, 
	122, 0
]

class << self
	attr_accessor :_fsm_single_lengths
	private :_fsm_single_lengths, :_fsm_single_lengths=
end
self._fsm_single_lengths = [
	0, 9, 1, 1, 7, 1, 2, 2, 
	4, 1, 2, 2, 4, 0, 1, 1, 
	7, 0, 0, 2, 0, 1, 2, 3, 
	3, 3, 3, 2, 4, 3, 2, 3, 
	3, 3, 3, 2, 1, 1, 2, 3, 
	3, 3, 3, 2, 4, 3, 2, 3, 
	3, 3, 3, 2, 0, 0, 7, 1, 
	2, 1, 2, 0, 2, 0, 1, 2, 
	3, 3, 3, 3, 2, 4, 3, 2, 
	3, 3, 3, 3, 2, 1, 1, 0, 
	1, 0, 1, 1, 1, 0, 2, 2, 
	2, 2, 1, 3, 2, 1, 2, 2, 
	2, 2, 1
]

class << self
	attr_accessor :_fsm_range_lengths
	private :_fsm_range_lengths, :_fsm_range_lengths=
end
self._fsm_range_lengths = [
	0, 3, 0, 0, 3, 0, 0, 0, 
	3, 0, 0, 0, 3, 1, 1, 1, 
	3, 0, 1, 1, 1, 1, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 1, 0, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 1, 1, 3, 0, 
	0, 0, 0, 1, 1, 1, 1, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3, 3, 3, 0, 0, 0, 
	1, 1, 3, 0, 0, 0, 3, 3, 
	3, 3, 3, 3, 3, 3, 3, 3, 
	3, 3, 3
]

class << self
	attr_accessor :_fsm_index_offsets
	private :_fsm_index_offsets, :_fsm_index_offsets=
end
self._fsm_index_offsets = [
	0, 0, 13, 15, 17, 28, 30, 33, 
	36, 44, 46, 49, 52, 60, 62, 65, 
	68, 79, 80, 82, 86, 88, 91, 97, 
	104, 111, 118, 125, 131, 139, 146, 152, 
	159, 166, 173, 180, 186, 189, 191, 197, 
	204, 211, 218, 225, 231, 239, 246, 252, 
	259, 266, 273, 280, 286, 288, 290, 301, 
	303, 306, 308, 311, 313, 317, 319, 322, 
	328, 335, 342, 349, 356, 362, 370, 377, 
	383, 390, 397, 404, 411, 417, 419, 421, 
	422, 425, 427, 432, 434, 436, 437, 443, 
	449, 455, 461, 466, 473, 479, 484, 490, 
	496, 502, 508
]

class << self
	attr_accessor :_fsm_trans_targs
	private :_fsm_trans_targs, :_fsm_trans_targs=
end
self._fsm_trans_targs = [
	2, 3, 4, 52, 52, 54, 86, 91, 
	95, 80, 82, 82, 0, 77, 2, 78, 
	3, 5, 9, 13, 13, 39, 44, 48, 
	14, 38, 38, 0, 6, 5, 6, 7, 
	5, 6, 8, 5, 6, 5, 5, 5, 
	5, 5, 5, 5, 10, 9, 10, 11, 
	9, 10, 12, 9, 9, 10, 9, 9, 
	9, 9, 9, 9, 14, 0, 15, 14, 
	0, 16, 36, 0, 17, 17, 18, 18, 
	23, 28, 32, 19, 22, 22, 0, 17, 
	19, 0, 79, 20, 19, 0, 21, 0, 
	79, 21, 0, 79, 22, 22, 22, 22, 
	0, 79, 22, 24, 22, 22, 22, 0, 
	79, 22, 25, 22, 22, 22, 0, 79, 
	22, 26, 22, 22, 22, 0, 79, 22, 
	27, 22, 22, 22, 0, 79, 22, 22, 
	22, 22, 0, 79, 22, 29, 31, 22, 
	22, 22, 0, 79, 22, 30, 22, 22, 
	22, 0, 79, 22, 22, 22, 22, 0, 
	79, 22, 29, 22, 22, 22, 0, 79, 
	22, 33, 22, 22, 22, 0, 79, 22, 
	34, 22, 22, 22, 0, 79, 22, 35, 
	22, 22, 22, 0, 79, 22, 22, 22, 
	22, 0, 37, 36, 0, 16, 0, 37, 
	38, 38, 38, 38, 0, 37, 38, 40, 
	38, 38, 38, 0, 37, 38, 41, 38, 
	38, 38, 0, 37, 38, 42, 38, 38, 
	38, 0, 37, 38, 43, 38, 38, 38, 
	0, 37, 38, 38, 38, 38, 0, 37, 
	38, 45, 47, 38, 38, 38, 0, 37, 
	38, 46, 38, 38, 38, 0, 37, 38, 
	38, 38, 38, 0, 37, 38, 45, 38, 
	38, 38, 0, 37, 38, 49, 38, 38, 
	38, 0, 37, 38, 50, 38, 38, 38, 
	0, 37, 38, 51, 38, 38, 38, 0, 
	37, 38, 38, 38, 38, 0, 80, 0, 
	81, 0, 55, 57, 59, 59, 64, 69, 
	73, 60, 63, 63, 0, 56, 55, 56, 
	83, 55, 58, 57, 58, 84, 57, 60, 
	0, 61, 85, 60, 0, 62, 0, 85, 
	62, 0, 85, 63, 63, 63, 63, 0, 
	85, 63, 65, 63, 63, 63, 0, 85, 
	63, 66, 63, 63, 63, 0, 85, 63, 
	67, 63, 63, 63, 0, 85, 63, 68, 
	63, 63, 63, 0, 85, 63, 63, 63, 
	63, 0, 85, 63, 70, 72, 63, 63, 
	63, 0, 85, 63, 71, 63, 63, 63, 
	0, 85, 63, 63, 63, 63, 0, 85, 
	63, 70, 63, 63, 63, 0, 85, 63, 
	74, 63, 63, 63, 0, 85, 63, 75, 
	63, 63, 63, 0, 85, 63, 76, 63, 
	63, 63, 0, 85, 63, 63, 63, 63, 
	0, 77, 2, 78, 3, 0, 53, 80, 
	0, 81, 0, 82, 82, 82, 82, 0, 
	56, 55, 58, 57, 0, 82, 87, 82, 
	82, 82, 0, 82, 88, 82, 82, 82, 
	0, 82, 89, 82, 82, 82, 0, 82, 
	90, 82, 82, 82, 0, 82, 82, 82, 
	82, 0, 82, 92, 94, 82, 82, 82, 
	0, 82, 93, 82, 82, 82, 0, 82, 
	82, 82, 82, 0, 82, 92, 82, 82, 
	82, 0, 82, 96, 82, 82, 82, 0, 
	82, 97, 82, 82, 82, 0, 82, 98, 
	82, 82, 82, 0, 82, 82, 82, 82, 
	0, 0
]

class << self
	attr_accessor :_fsm_trans_actions
	private :_fsm_trans_actions, :_fsm_trans_actions=
end
self._fsm_trans_actions = [
	1, 1, 0, 1, 1, 0, 1, 1, 
	1, 1, 1, 1, 0, 0, 0, 0, 
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 0, 0, 0, 0, 17, 
	0, 0, 0, 0, 1, 1, 1, 1, 
	1, 1, 1, 0, 0, 0, 0, 17, 
	0, 0, 0, 0, 1, 1, 1, 1, 
	1, 1, 1, 0, 0, 0, 7, 0, 
	0, 0, 0, 0, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 0, 0, 
	0, 0, 7, 0, 0, 0, 0, 0, 
	9, 0, 0, 19, 0, 0, 0, 0, 
	0, 19, 0, 0, 0, 0, 0, 0, 
	19, 0, 0, 0, 0, 0, 0, 19, 
	0, 0, 0, 0, 0, 0, 19, 0, 
	0, 0, 0, 0, 0, 15, 0, 0, 
	0, 0, 0, 19, 0, 0, 0, 0, 
	0, 0, 0, 19, 0, 0, 0, 0, 
	0, 0, 11, 0, 0, 0, 0, 0, 
	19, 0, 0, 0, 0, 0, 0, 19, 
	0, 0, 0, 0, 0, 0, 19, 0, 
	0, 0, 0, 0, 0, 19, 0, 0, 
	0, 0, 0, 0, 13, 0, 0, 0, 
	0, 0, 9, 0, 0, 0, 0, 19, 
	0, 0, 0, 0, 0, 19, 0, 0, 
	0, 0, 0, 0, 19, 0, 0, 0, 
	0, 0, 0, 19, 0, 0, 0, 0, 
	0, 0, 19, 0, 0, 0, 0, 0, 
	0, 15, 0, 0, 0, 0, 0, 19, 
	0, 0, 0, 0, 0, 0, 0, 19, 
	0, 0, 0, 0, 0, 0, 11, 0, 
	0, 0, 0, 0, 19, 0, 0, 0, 
	0, 0, 0, 19, 0, 0, 0, 0, 
	0, 0, 19, 0, 0, 0, 0, 0, 
	0, 19, 0, 0, 0, 0, 0, 0, 
	13, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 0, 0, 0, 0, 
	17, 0, 0, 0, 0, 17, 0, 0, 
	0, 0, 7, 0, 0, 0, 0, 9, 
	0, 0, 19, 0, 0, 0, 0, 0, 
	19, 0, 0, 0, 0, 0, 0, 19, 
	0, 0, 0, 0, 0, 0, 19, 0, 
	0, 0, 0, 0, 0, 19, 0, 0, 
	0, 0, 0, 0, 15, 0, 0, 0, 
	0, 0, 19, 0, 0, 0, 0, 0, 
	0, 0, 19, 0, 0, 0, 0, 0, 
	0, 11, 0, 0, 0, 0, 0, 19, 
	0, 0, 0, 0, 0, 0, 19, 0, 
	0, 0, 0, 0, 0, 19, 0, 0, 
	0, 0, 0, 0, 19, 0, 0, 0, 
	0, 0, 0, 13, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0
]

class << self
	attr_accessor :_fsm_eof_actions
	private :_fsm_eof_actions, :_fsm_eof_actions=
end
self._fsm_eof_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 17, 17, 5, 
	7, 9, 19, 3, 3, 3, 19, 19, 
	19, 19, 15, 19, 19, 11, 19, 19, 
	19, 19, 13
]

class << self
	attr_accessor :fsm_start
end
self.fsm_start = 1;
class << self
	attr_accessor :fsm_first_final
end
self.fsm_first_final = 77;
class << self
	attr_accessor :fsm_error
end
self.fsm_error = 0;

class << self
	attr_accessor :fsm_en_main
end
self.fsm_en_main = 1;


# line 98 "./lib/liquid/parser.rl"

    def self.emit(sym, type, data, tokens) 
      puts "emitting: #{type} #{sym} -> #{data.inspect}"
      tokens.push [sym, data]
    end

    def self.parse(data)      
      eof = data.length  
      tokens = []

      
# line 414 "./lib/liquid/parser.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = fsm_start
end

# line 109 "./lib/liquid/parser.rl"
      
# line 423 "./lib/liquid/parser.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _fsm_key_offsets[cs]
	_trans = _fsm_index_offsets[cs]
	_klen = _fsm_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _fsm_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _fsm_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _fsm_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _fsm_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _fsm_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _fsm_trans_targs[_trans]
	if _fsm_trans_actions[_trans] != 0
		_acts = _fsm_trans_actions[_trans]
		_nacts = _fsm_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _fsm_actions[_acts - 1]
when 0 then
# line 34 "./lib/liquid/parser.rl"
		begin

    mark = p
  		end
when 3 then
# line 59 "./lib/liquid/parser.rl"
		begin
 emit(:id, :integer, Integer(data[mark..p-1]), tokens) 		end
when 4 then
# line 61 "./lib/liquid/parser.rl"
		begin
 emit(:id, :float, Float(data[mark..p-1]), tokens) 		end
when 5 then
# line 63 "./lib/liquid/parser.rl"
		begin
 emit(:id, :nil, nil, tokens) 		end
when 6 then
# line 64 "./lib/liquid/parser.rl"
		begin
 emit(:id, :bool, true, tokens) 		end
when 7 then
# line 65 "./lib/liquid/parser.rl"
		begin
 emit(:id, :bool, false, tokens)		end
when 8 then
# line 67 "./lib/liquid/parser.rl"
		begin
 emit(:id, :string, data[mark+1..p-2], tokens) 		end
when 9 then
# line 74 "./lib/liquid/parser.rl"
		begin
 
      emit(:id, :label, data[mark..p-1], tokens) 
      emit(:lookup, :variable, nil, tokens) 
    		end
# line 540 "./lib/liquid/parser.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	__acts = _fsm_eof_actions[cs]
	__nacts =  _fsm_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _fsm_actions[__acts - 1]
when 1 then
# line 38 "./lib/liquid/parser.rl"
		begin

    emit(:lookup, :instruction, nil, tokens)
  		end
when 2 then
# line 42 "./lib/liquid/parser.rl"
		begin

    emit(:range, :instruction, nil, tokens)
  		end
when 3 then
# line 59 "./lib/liquid/parser.rl"
		begin
 emit(:id, :integer, Integer(data[mark..p-1]), tokens) 		end
when 4 then
# line 61 "./lib/liquid/parser.rl"
		begin
 emit(:id, :float, Float(data[mark..p-1]), tokens) 		end
when 5 then
# line 63 "./lib/liquid/parser.rl"
		begin
 emit(:id, :nil, nil, tokens) 		end
when 6 then
# line 64 "./lib/liquid/parser.rl"
		begin
 emit(:id, :bool, true, tokens) 		end
when 7 then
# line 65 "./lib/liquid/parser.rl"
		begin
 emit(:id, :bool, false, tokens)		end
when 8 then
# line 67 "./lib/liquid/parser.rl"
		begin
 emit(:id, :string, data[mark+1..p-2], tokens) 		end
when 9 then
# line 74 "./lib/liquid/parser.rl"
		begin
 
      emit(:id, :label, data[mark..p-1], tokens) 
      emit(:lookup, :variable, nil, tokens) 
    		end
# line 611 "./lib/liquid/parser.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 110 "./lib/liquid/parser.rl"
      return tokens 
    end
  end
end