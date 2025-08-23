require 'digest'

module Jekyll
  class AssetHashTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end

    def render(context)
      site = context.registers[:site]
      file_path = File.join(site.source, @text)

      if File.exist?(file_path)
        content = File.read(file_path)
        hash = Digest::MD5.hexdigest(content)[0..7]
        "#{@text}?v=#{hash}"
      else
        @text
      end
    end
  end
end

Liquid::Template.register_tag('asset_hash', Jekyll::AssetHashTag)
