class SimplePdfRenderer
  def self.render(title, lines)
    new(title, lines).render
  end

  def initialize(title, lines)
    @title = title
    @lines = lines
  end

  def render
    body = ([title] + lines).each_with_index.map do |line, index|
      "BT /F1 12 Tf 50 #{760 - (index * 18)} Td (#{escape_pdf(line)}) Tj ET"
    end.join("\n")
    objects = [
      "<< /Type /Catalog /Pages 2 0 R >>",
      "<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
      "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>",
      "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
      "<< /Length #{body.bytesize} >>\nstream\n#{body}\nendstream"
    ]
    build_pdf(objects)
  end

  private

  attr_reader :title, :lines

  def build_pdf(objects)
    pdf = +"%PDF-1.4\n"
    offsets = []
    objects.each_with_index do |object, index|
      offsets << pdf.bytesize
      pdf << "#{index + 1} 0 obj\n#{object}\nendobj\n"
    end
    xref = pdf.bytesize
    pdf << "xref\n0 #{objects.size + 1}\n0000000000 65535 f \n"
    offsets.each { |offset| pdf << format("%010d 00000 n \n", offset) }
    pdf << "trailer << /Size #{objects.size + 1} /Root 1 0 R >>\nstartxref\n#{xref}\n%%EOF\n"
  end

  def escape_pdf(value)
    value.to_s.gsub("\\", "\\\\\\").gsub("(", "\\(").gsub(")", "\\)")
  end
end
