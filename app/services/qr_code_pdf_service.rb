# frozen_string_literal: true

class QrCodePdfService
  require 'prawn'

  def initialize(object)
    @object = object
  end

  def generate_warehouse_label
    Prawn::Document.new(page_size: 'A4', margin: 20) do |pdf|
      # Title
      pdf.font_size 20
      pdf.text "FlowTrace - Depo Etiketi", align: :center, style: :bold
      pdf.move_down 20

      # QR Code
      if @object.qr_code
        qr_image_path = Rails.root.join('public', 'qr_codes', 'warehouses', "#{@object.qr_code}.png")
        if File.exist?(qr_image_path)
          pdf.image qr_image_path, at: [pdf.bounds.width/2 - 100, pdf.cursor], width: 200, height: 200
          pdf.move_down 220
        end
      end

      # Warehouse Info
      pdf.font_size 14
      pdf.text "Depo Bilgileri:", style: :bold
      pdf.move_down 10

      info_table = [
        ["QR Kod:", @object.qr_code || "Henüz oluşturulmamış"],
        ["Depo Adı:", @object.name],
        ["Konum:", @object.location || "Belirtilmemiş"],
        ["Kapasite:", @object.capacity ? "#{@object.capacity} eşya" : "Sınırsız"],
        ["Durum:", @object.status&.humanize || "Aktif"],
        ["Açıklama:", @object.description || "Açıklama bulunmuyor"]
      ]

      pdf.table(info_table,
                cell_style: { padding: 8, border_width: 1 },
                column_widths: [120, 350],
                row_colors: ["FFFFFF", "F0F0F0"])

      pdf.move_down 20

      # Footer
      pdf.font_size 10
      pdf.text "Oluşturulma: #{Time.current.strftime('%d.%m.%Y %H:%M')}", align: :right
      pdf.text "FlowTrace Envanter Yönetim Sistemi", align: :center, style: :italic
    end.render
  end

  def generate_item_label
    Prawn::Document.new(page_size: 'A4', margin: 20) do |pdf|
      # Title
      pdf.font_size 20
      pdf.text "FlowTrace - Eşya Etiketi", align: :center, style: :bold
      pdf.move_down 20

      # QR Code
      if @object.qr_code
        qr_image_path = Rails.root.join('public', 'qr_codes', 'items', "#{@object.qr_code}.png")
        if File.exist?(qr_image_path)
          pdf.image qr_image_path, at: [pdf.bounds.width/2 - 100, pdf.cursor], width: 200, height: 200
          pdf.move_down 220
        end
      end

      # Item Info
      pdf.font_size 14
      pdf.text "Eşya Bilgileri:", style: :bold
      pdf.move_down 10

      info_table = [
        ["QR Kod:", @object.qr_code || "Henüz oluşturulmamış"],
        ["Eşya Adı:", @object.name],
        ["Kategori:", @object.category || "Belirtilmemiş"],
        ["Marka:", @object.brand || "Belirtilmemiş"],
        ["Model:", @object.model || "Belirtilmemiş"],
        ["Seri No:", @object.serial_number || "Belirtilmemiş"],
        ["Durum:", @object.status&.humanize || "Stokta"],
        ["Depo:", @object.warehouse&.name || "Atanmamış"],
        ["Değer:", @object.value ? "#{@object.value} TL" : "Belirtilmemiş"],
        ["Açıklama:", @object.description || "Açıklama bulunmuyor"]
      ]

      pdf.table(info_table,
                cell_style: { padding: 8, border_width: 1 },
                column_widths: [120, 350],
                row_colors: ["FFFFFF", "F0F0F0"])

      pdf.move_down 20

      # Transaction History
      if @object.transactions.any?
        pdf.font_size 14
        pdf.text "Son İşlemler:", style: :bold
        pdf.move_down 10

        transaction_data = @object.transactions.recent.limit(10).map do |t|
          [
            t.created_at.strftime('%d.%m.%Y'),
            t.action_type == 'checkout' ? 'Çıkış' : 'Giriş',
            t.user.name,
            t.destination || '-'
          ]
        end

        transaction_headers = ["Tarih", "İşlem", "Kullanıcı", "Hedef"]

        pdf.table([transaction_headers] + transaction_data,
                  header: true,
                  cell_style: { padding: 6, border_width: 1 },
                  column_widths: [80, 80, 120, 190],
                  row_colors: ["FFFFFF", "F8F8F8"])
      end

      pdf.move_down 20

      # Footer
      pdf.font_size 10
      pdf.text "Oluşturulma: #{Time.current.strftime('%d.%m.%Y %H:%M')}", align: :right
      pdf.text "FlowTrace Envanter Yönetim Sistemi", align: :center, style: :italic
    end.render
  end

  def generate_bulk_labels(objects)
    Prawn::Document.new(page_size: 'A4', margin: 20) do |pdf|
      objects.each_with_index do |object, index|
        pdf.start_new_page if index > 0

        if object.is_a?(Warehouse)
          generate_warehouse_content(pdf, object)
        elsif object.is_a?(Item)
          generate_item_content(pdf, object)
        end
      end
    end.render
  end

  private

  def generate_warehouse_content(pdf, warehouse)
    pdf.font_size 16
    pdf.text "Depo: #{warehouse.name}", style: :bold
    pdf.move_down 10

    if warehouse.qr_code
      qr_image_path = Rails.root.join('public', 'qr_codes', 'warehouses', "#{warehouse.qr_code}.png")
      if File.exist?(qr_image_path)
        pdf.image qr_image_path, width: 150, height: 150
        pdf.move_down 10
      end
    end

    pdf.font_size 12
    pdf.text "QR Kod: #{warehouse.qr_code}"
    pdf.text "Konum: #{warehouse.location}"
    pdf.text "Kapasite: #{warehouse.capacity || 'Sınırsız'}"
  end

  def generate_item_content(pdf, item)
    pdf.font_size 16
    pdf.text "Eşya: #{item.name}", style: :bold
    pdf.move_down 10

    if item.qr_code
      qr_image_path = Rails.root.join('public', 'qr_codes', 'items', "#{item.qr_code}.png")
      if File.exist?(qr_image_path)
        pdf.image qr_image_path, width: 150, height: 150
        pdf.move_down 10
      end
    end

    pdf.font_size 12
    pdf.text "QR Kod: #{item.qr_code}"
    pdf.text "Kategori: #{item.category}"
    pdf.text "Marka: #{item.brand}" if item.brand
    pdf.text "Seri No: #{item.serial_number}" if item.serial_number
    pdf.text "Depo: #{item.warehouse&.name || 'Atanmamış'}"
  end
end
