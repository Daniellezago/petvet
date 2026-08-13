module ApplicationHelper
  def mascarar_cpf(cpf)
    return "-" if cpf.blank?

    digitos = cpf.gsub(/\D/, "")
    return cpf if digitos.length != 11

    "#{digitos[0..2]}.***.***-#{digitos[-2..]}"
end

def mascarar_telefone(telefone)
    return "-" if telefone.blank?

    digitos = telefone.gsub(/\D/, "")
    return telefone if digitos.length < 10

    "(#{digitos[0..1]}) #{digitos[2..-5]}**-**#{digitos[-2..]}"
  end

  # Gera a lista de páginas a exibir na paginação, com marcadores de "..." (gap)
  # Ex.: pagina atual 5 de 10 -> [1, :gap, 4, 5, 6, :gap, 10]
  def kaminari_page_range(total_pages, current_page, window: 1)
      return (1..total_pages).to_a if total_pages <= 7

      pages = [ 1, total_pages ]
      (current_page - window..current_page + window).each { |p| pages << p if p.between?(1, total_pages) }
      pages = pages.uniq.sort

      resultado = []
      pages.each_with_index do |page, i|
        resultado << page
        proximo = pages[i + 1]
        resultado << :gap if proximo && proximo - page > 1
    end
    resultado
  end
end
