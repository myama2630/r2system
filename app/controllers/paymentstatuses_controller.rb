class PaymentstatusesController < ApplicationController
  before_action :set_paymentstatus, only: [:show, :edit, :update, :destroy]

  # GET /paymentstatuses
  # GET /paymentstatuses.json
  def index
    @paymentstatuses = Paymentstatus.all
  end

  # GET /paymentstatuses/1
  # GET /paymentstatuses/1.json
  def show
  end

  # GET /paymentstatuses/new
  def new
    @paymentstatus = Paymentstatus.new
  end

  # GET /paymentstatuses/1/edit
  def edit
  end

  # POST /paymentstatuses
  # POST /paymentstatuses.json
  def create
    @paymentstatus = Paymentstatus.new(paymentstatus_params)

    respond_to do |format|
      if @paymentstatus.save
        format.html { redirect_to @paymentstatus, notice: 'Paymentstatus was successfully created.' }
        format.json { render action: 'show', status: :created, location: @paymentstatus }
      else
        format.html { render action: 'new' }
        format.json { render json: @paymentstatus.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /paymentstatuses/1
  # PATCH/PUT /paymentstatuses/1.json
  def update
    respond_to do |format|
      if @paymentstatus.update(paymentstatus_params)
        format.html { redirect_to @paymentstatus, notice: 'Paymentstatus was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @paymentstatus.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /paymentstatuses/1
  # DELETE /paymentstatuses/1.json
  def destroy
    @paymentstatus.destroy
    respond_to do |format|
      format.html { redirect_to paymentstatuses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paymentstatus
      @paymentstatus = Paymentstatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def paymentstatus_params
      params.require(:paymentstatus).permit(:name)
    end
end
