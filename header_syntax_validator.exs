defmodule HeaderValidator do

    def validate_header([head|tail], header) do
        if has_field?(head, header) do
            validate_header(tail, header)
        else
            :invalid
        end
    end


    def validate_header([], _header) do
        :valid
    end


    defp has_field?(field, header) do
        Map.has_key?(header, field)
    end

end
