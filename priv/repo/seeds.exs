alias Ledger.{Usuarios.Usuarios, Monedas.Monedas, Transacciones.Transacciones}

usuarios = [
  %{nombre: "Isabella Cruz", fecha_nacimiento: ~D[1992-12-28]},
  %{nombre: "Mateo García", fecha_nacimiento: ~D[1988-07-14]},
  %{nombre: "Sofía López", fecha_nacimiento: ~D[1995-03-22]},
  %{nombre: "Liam Fernández", fecha_nacimiento: ~D[1990-11-05]},
  %{nombre: "Valentina Martínez", fecha_nacimiento: ~D[1985-09-30]},
  %{nombre: "Lucas Rodríguez", fecha_nacimiento: ~D[1993-06-17]},
  %{nombre: "Camila González", fecha_nacimiento: ~D[1998-01-09]},
  %{nombre: "Benjamín Sánchez", fecha_nacimiento: ~D[1987-08-21]},
  %{nombre: "Emma Romero", fecha_nacimiento: ~D[1994-05-12]},
  %{nombre: "Matías Torres", fecha_nacimiento: ~D[1991-02-03]},
  %{nombre: "Amelia Díaz", fecha_nacimiento: ~D[1989-12-15]},
  %{nombre: "Santiago Pérez", fecha_nacimiento: ~D[1996-04-27]},
  %{nombre: "Mía Ramírez", fecha_nacimiento: ~D[1992-10-08]},
  %{nombre: "Tomás Herrera", fecha_nacimiento: ~D[1986-07-19]},
  %{nombre: "Victoria Castro", fecha_nacimiento: ~D[1997-03-05]},
  %{nombre: "Martín Morales", fecha_nacimiento: ~D[1990-09-23]},
  %{nombre: "Lucía Vega", fecha_nacimiento: ~D[1993-11-11]},
  %{nombre: "Gabriel Ortiz", fecha_nacimiento: ~D[1988-01-29]},
  %{nombre: "Valeria Cruz", fecha_nacimiento: ~D[1995-06-06]},
  %{nombre: "Diego Flores", fecha_nacimiento: ~D[1991-08-16]}
]

for attrs <- usuarios do
  case Usuarios.crear_usuario(attrs) do
    {:ok, _usuario} -> :ok
    {:error, reason} -> IO.puts("Error al crear usuario #{attrs.nombre}: #{inspect(reason)}")
  end
end

monedas = [
  %{nombre: "BTC", precio_dolares: Decimal.new("50000")},
  %{nombre: "ETH", precio_dolares: Decimal.new("3500")},
  %{nombre: "ADA", precio_dolares: Decimal.new("2.3")},
  %{nombre: "SOL", precio_dolares: Decimal.new("150")},
  %{nombre: "DOT", precio_dolares: Decimal.new("35")},
  %{nombre: "LTC", precio_dolares: Decimal.new("180")},
  %{nombre: "DOGE", precio_dolares: Decimal.new("0.25")},
  %{nombre: "XRP", precio_dolares: Decimal.new("1.1")},
  %{nombre: "AVAX", precio_dolares: Decimal.new("80")},
  %{nombre: "LINK", precio_dolares: Decimal.new("28")}
]

for attrs <- monedas do
  case Monedas.crear_moneda(attrs) do
    {:ok, _moneda} -> :ok
    {:error, reason} -> IO.puts("Error al crear moneda #{attrs.nombre}: #{inspect(reason)}")
  end
end

cuentas_attrs = [
  %{cuenta_destino_id: 1, moneda_destino_id: 1, monto: 0.75},
  %{cuenta_destino_id: 2, moneda_destino_id: 2, monto: 10},
  %{cuenta_destino_id: 3, moneda_destino_id: 3, monto: 200},
  %{cuenta_destino_id: 4, moneda_destino_id: 4, monto: 50},
  %{cuenta_destino_id: 5, moneda_destino_id: 5, monto: 150},
  %{cuenta_destino_id: 6, moneda_destino_id: 6, monto: 3},
  %{cuenta_destino_id: 7, moneda_destino_id: 7, monto: 1000},
  %{cuenta_destino_id: 8, moneda_destino_id: 8, monto: 500},
  %{cuenta_destino_id: 9, moneda_destino_id: 9, monto: 0.8},
  %{cuenta_destino_id: 10, moneda_destino_id: 10, monto: 70}
]

for attrs <- cuentas_attrs do
  case Transacciones.alta_cuenta(Map.put(attrs, :tipo, "alta")) do
    {:ok, _cuenta} -> :ok
    {:error, reason} -> IO.puts("Error al crear cuenta para usuario #{attrs.cuenta_destino_id}: #{inspect(reason)}")
  end
end

transferencias_attrs = [
  %{cuenta_origen_id: 1, cuenta_destino_id: 2, moneda_origen_id: 1, monto: 0.25},
  %{cuenta_origen_id: 3, cuenta_destino_id: 4, moneda_origen_id: 3, monto: 100},
  %{cuenta_origen_id: 2, cuenta_destino_id: 5, moneda_origen_id: 2, monto: 5},
  %{cuenta_origen_id: 5, cuenta_destino_id: 6, moneda_origen_id: 5, monto: 50},
  %{cuenta_origen_id: 7, cuenta_destino_id: 1, moneda_origen_id: 7, monto: 200},
  %{cuenta_origen_id: 8, cuenta_destino_id: 3, moneda_origen_id: 8, monto: 100},
  %{cuenta_origen_id: 9, cuenta_destino_id: 4, moneda_origen_id: 9, monto: 0.3},
  %{cuenta_origen_id: 10, cuenta_destino_id: 2, moneda_origen_id: 10, monto: 20},
  %{cuenta_origen_id: 6, cuenta_destino_id: 1, moneda_origen_id: 6, monto: 1.5},
  %{cuenta_origen_id: 4, cuenta_destino_id: 5, moneda_origen_id: 4, monto: 25}
]

for attrs <- transferencias_attrs do
  attrs = Map.put(attrs, :tipo, "transferencia")

  case Transacciones.realizar_transferencia(attrs) do
    {:ok, _transferencia} -> :ok
    {:error, reason} -> IO.puts("Error en transferencia de #{attrs.cuenta_origen_id} a #{attrs.cuenta_destino_id}: #{inspect(reason)}")
  end
end

swaps_attrs = [
  %{cuenta_destino_id: 1, moneda_origen_id: 1, moneda_destino_id: 2, monto: 0.10},  # BTC → ETH
  %{cuenta_destino_id: 2, moneda_origen_id: 2, moneda_destino_id: 3, monto: 1.0},   # ETH → ADA
  %{cuenta_destino_id: 3, moneda_origen_id: 3, moneda_destino_id: 4, monto: 50},    # ADA → SOL
  %{cuenta_destino_id: 4, moneda_origen_id: 4, moneda_destino_id: 5, monto: 10},    # SOL → DOT
  %{cuenta_destino_id: 5, moneda_origen_id: 5, moneda_destino_id: 6, monto: 20},    # DOT → LTC
  %{cuenta_destino_id: 6, moneda_origen_id: 6, moneda_destino_id: 7, monto: 1.0},   # LTC → DOGE
  %{cuenta_destino_id: 7, moneda_origen_id: 7, moneda_destino_id: 8, monto: 100},   # DOGE → XRP
  %{cuenta_destino_id: 8, moneda_origen_id: 8, moneda_destino_id: 9, monto: 50},    # XRP → AVAX
  %{cuenta_destino_id: 9, moneda_origen_id: 9, moneda_destino_id: 10, monto: 0.2},  # AVAX → LINK
  %{cuenta_destino_id: 10, moneda_origen_id: 10, moneda_destino_id: 1, monto: 10}   # LINK → BTC
]

for attrs <- swaps_attrs do
  case Transacciones.realizar_swap(Map.put(attrs, :tipo, "swap")) do
    {:ok, _swap} -> :ok
    {:error, reason} -> IO.puts("Error en swap para cuenta #{attrs.cuenta_destino_id}: #{inspect(reason)}")
  end
end
