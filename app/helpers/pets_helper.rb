module PetsHelper
  # Mesmo padrão de ordenação usado em Tutores, mas apontando pra pets_path
  def pet_sortable_column_link(label, column)
    ordenando_por_esta_coluna = params[:sort] == column
    nova_direcao = ordenando_por_esta_coluna && params[:direction] != "desc" ? "desc" : "asc"

    icone = if ordenando_por_esta_coluna
      params[:direction] == "desc" ? "chevron-down" : "chevron-up"
    else
      "chevrons-up-down"
    end

    link_to pets_path(request.query_parameters.merge(sort: column, direction: nova_direcao, page: nil)),
            class: "inline-flex items-center gap-1 hover:text-gray-700" do
      concat label
      concat content_tag(:i, "", data: { lucide: icone },
        class: "w-3 h-3 #{'text-emerald-600' if ordenando_por_esta_coluna}")
    end
  end

  # Foto do pet, ou um círculo colorido com as iniciais quando não há foto
  def pet_avatar(pet)
    if pet.foto.attached?
      image_tag pet.foto, class: "w-10 h-10 rounded-full object-cover shrink-0"
    else
      cores = %w[bg-purple-500 bg-blue-500 bg-emerald-500 bg-amber-500 bg-pink-500 bg-indigo-500 bg-rose-500 bg-teal-500]
      cor = cores[pet.id.to_i % cores.length]
      iniciais = pet.nome.to_s.strip[0..1].upcase
      content_tag :div, iniciais,
        class: "w-10 h-10 rounded-full #{cor} text-white flex items-center justify-center text-xs font-semibold shrink-0"
    end
  end
end
