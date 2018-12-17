class StatementsController < ApplicationController
  before_action :set_statement, only: [:show, :update, :destroy]
  before_action :set_account

  # GET /accounts/:account_id/statements
  def index
    @statements = Statement.where(account: @account).order(updated_at: "DESC")

    render json: @statements
  end

  # GET /accounts/:account_id/statements/1
  def show
    render json: @statement
  end

  # GET /accounts/:account_id/account_to/:to/amount/:amount/transfer
  def transfer
    amount = params[:amount].to_i
    account_to = Account.find(params[:to])
    statement_to = account_to.statements.order(updated_at: "desc").first
    statement_from = @account.statements.order(updated_at: "desc").first

    @statement_from = @account.statements.build(
      date: Time.new.to_date,
      kind: "出",
      amount: amount,
      memo: "振込",
      total: statement_from.total - amount
    )

    @statement_to = account_to.statements.build(
      date: Date.new,
      kind: "入",
      amount: amount,
      memo: "振込",
      total: statement_to.total + amount
    )

    if @statement_from.save && @statement_from.save
      render json: @statement_from, status: :created, location: @account
    else
      render json: @statement_from, status: :unprocessable_entity
    end
  end

  # POST /accounts/:account_id/statements
  def create
    @statement = Statement.new(statement_params)

    if @statement.save
      render json: @statement, status: :created, location: @statement
    else
      render json: @statement.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/:account_id/statements/1
  def update
    if @statement.update(statement_params)
      render json: @statement
    else
      render json: @statement.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/:account_id/statements/1
  def destroy
    @statement.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_statement
      @statement = Statement.find(params[:id])
    end

    def set_account
      @account = Account.find(params[:account_id])
    end

    # Only allow a trusted parameter "white list" through.
    def statement_params
      params.require(:statement).permit(:date, :type, :amount, :memo, :total, :account_id)
    end
end
