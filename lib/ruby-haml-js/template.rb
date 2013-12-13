require 'tilt/template'

module RubyHamlJs
  class Template < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      defined? ::ExecJS
    end

    def initialize_engine
      require_template_library 'execjs'
    end
    
    def prepare
    end

    # Compiles the template using HAML-JS
    #
    # Returns a JS function definition String. The result should be
    # assigned to a JS variable.
    #
    #     # => "function(data) { ... }"
    def evaluate(scope, locals, &block)
      compile_to_function
    end



    private

    def compile_to_function
      args = [data, {
        escapeHtmlByDefault: false, 
        customEscape: self.class.custom_escape || false
      }]
      function = ExecJS.
        compile(self.class.haml_source).
        eval "Haml.apply(this, #{::JSON.generate(args)}).toString()"
      # make sure function is annonymous
      function.sub /function \w+/, "function "
    end

    class << self
      attr_accessor :custom_escape
      attr_accessor :haml_path

      def haml_source
        # Haml source is an asset
        @haml_path = File.expand_path('../../../vendor/assets/javascripts/haml.js', __FILE__) if @haml_path.nil?
        @haml_source ||= IO.read @haml_path
      end

    end

  end
end

