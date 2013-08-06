module JSONBuilder
  class CachedBlock
    attr_reader :cache_key, :cache_opts, :content_block, :scope

    # Public: Creates a JSON block whose execution is deferred.
    # If a scope's fragment cache contains a record with a given key, it is being returned.
    # Otherwise, initially supplied block gets compiled, converted to string 
    # and written to the fragment cache.
    # 
    # cache_key - a fragment cache key
    # cache_opts - a fragment cache options
    # scope - scoping object from a parent compiler
    # block - block that will be executed to produce content
    # 
    def initialize(cache_key, cache_opts, scope, &block)
      @cache_key = cache_key
      @cache_opts = cache_opts
      @content_block = block
      @scope = scope
    end

    def to_s
      if fragment = read_fragment
        fragment
      else
        json_data.tap { |str| write_fragment str }
      end
    end

    private

    def read_fragment
      scope.controller.read_fragment(cache_key, cache_opts)
    end

    def write_fragment(content)
      scope.controller.write_fragment(cache_key, content, cache_opts)
    end

    def json_data
      @data ||= Compiler.generate(scope: scope, &content_block)
    end
  end
end
