module TutoresHelper
  # Gera um cabeçalho de coluna clicável com setinha de ordenação (chevron-up/down).
  # Mantém busca e filtro de ativos/inativos na URL, e reseta a paginação.
  def sortable_column_link(label, column)
    ordenando_por_esta_coluna = params[:sort] == column
    nova_direcao = ordenando_por_esta_coluna && params[:direction] != "desc" ? "desc" : "asc"

    icone = if ordenando_por_esta_coluna
      params[:direction] == "desc" ? "chevron-down" : "chevron-up"
    else
      "chevrons-up-down"
    end

    link_to tutores_path(request.query_parameters.merge(sort: column, direction: nova_direcao, page: nil)),
            class: "inline-flex items-center gap-1 hover:text-gray-700" do
      concat label
      concat content_tag(:i, "", data: { lucide: icone },
        class: "w-3 h-3 #{'text-emerald-600' if ordenando_por_esta_coluna}")
    end
  end
end
