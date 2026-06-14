require "digest"

class CodeImageService
  def self.barcode_svg(value)
    new(value).barcode_svg
  end

  def self.qr_svg(value)
    new(value).qr_svg
  end

  def initialize(value)
    @value = value.to_s
  end

  def barcode_svg
    bars = digest_bits.first(48).chars.each_with_index.filter_map do |bit, index|
      width = bit == "1" ? 3 : 1
      x = 10 + (index * 4)
      %(<rect x="#{x}" y="10" width="#{width}" height="70" fill="#111827"/>)
    end.join
    svg(220, 100, "#{bars}<text x=\"10\" y=\"94\" font-size=\"10\">#{escaped_value}</text>")
  end

  def qr_svg
    cells = digest_bits.ljust(441, "0").chars.first(441).each_with_index.filter_map do |bit, index|
      next unless bit == "1"

      x = 8 + ((index % 21) * 6)
      y = 8 + ((index / 21) * 6)
      %(<rect x="#{x}" y="#{y}" width="6" height="6" fill="#111827"/>)
    end.join
    svg(142, 142, cells)
  end

  private

  attr_reader :value

  def digest_bits
    Digest::SHA256.hexdigest(value).hex.to_s(2)
  end

  def escaped_value
    ERB::Util.html_escape(value)
  end

  def svg(width, height, body)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{width}" height="#{height}" viewBox="0 0 #{width} #{height}"><rect width="100%" height="100%" fill="#fff"/>#{body}</svg>)
  end
end
