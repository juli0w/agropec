class OrdersController < ApplicationController
  before_filter :set_order, only: [:check_order, :destroy, :print, :pay, :pay_with_cash, :cancel, :open, :quote]
  before_action :authenticate_user!
  # before_action :authenticate_vendedor!

  def check_order
    @order.coupon = params[:value]
    @order.save
  end

  def index
    if current_user.admin?
      @orders = Order.not_empty
    else
      @orders = current_user.orders.not_empty.opened_and_quote
    end

    if params[:type].present?
      @orders = @orders.send(params[:type])
    end
    @orders = @orders.search(params[:keyword]).page(params[:page]).per(10).order("orders.submited_at DESC, orders.id DESC")
  end

  def edit
    session[:client] = Order.find(params[:id]).client_id
    session[:order_id] = params[:id]
    redirect_to root_path
  end

  def destroy
    @order.delete

    flash[:success] = "Pedido removido"
    redirect_to orders_path
  end

  def print
    render layout: nil
  end

  def pay
    @order.pay!

    redirect_to orders_path(type: params[:type]), notice: "Pagamento confirmado."
  end

  def pay_with_cash
    @order.pay_with_cash!

    redirect_to orders_path(type: params[:type]), notice: "Pagamento confirmado."
  end

  def quote
    @order.quote!

    redirect_to orders_path(type: params[:type]), notice: "Orçamento confirmado."
  end

  def cancel
    @order.cancel!

    redirect_to orders_path(type: params[:type]), notice: "Pedido cancelado."
  end

  def open
    @order.open!

    redirect_to orders_path(type: params[:type]), notice: "Pedido aberto."
  end

private

  def set_order
    @order = Order.find(params[:id])
  end
end
