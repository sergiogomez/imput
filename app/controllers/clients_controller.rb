class ClientsController < ApplicationController
  before_action :authorize_person!
  before_action :set_client, only: [:show, :edit, :update, :destroy, :disable, :enable]

  # GET /clients
  def index
    @clients = current_person.company.clients
    respond_to do |format|
      format.html
      format.xlsx
      format.csv { send_data @clients.to_csv }
    end
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  def create
    @client = Client.new(client_params)
    @client.company = current_person.company

    respond_to do |format|
      if @client.save
        format.html { redirect_to clients_url, notice: 'Client was successfully created.' }
        format.json {
          render json: {
            id: @client.id,
            name: @client.name
          },
          status: :created
        }
      else
        format.html { render :new }
        format.json { render json: { error: true, messages: @client.errors } }
      end
    end
  end

  # PATCH/PUT /clients/1
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to clients_url, notice: 'Client was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Client was successfully destroyed.' }
    end
  end

  # GET /clients/import
  def import
  end

  # POST /clients/import
  def import_file
    success, errors = Client.import(current_person, params[:file])
    flash[:notice] = success.join('<br />') if success.size > 0
    flash[:error] = errors.join('<br />') if errors.size > 0
    redirect_to clients_url
  end

  # PATCH /clients/1/disable
  def disable
    @client.enabled = false
    @client.save
    redirect_to request.referer
  end

  # PATCH /clients/1/enable
  def enable
    @client.enabled = true
    @client.save
    redirect_to request.referer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = current_person.company.clients.find_by(id: params[:id])
      redirect_to root_path if @client.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:name, :address, :notes)
    end

    def authorize_person!
      redirect_to root_path unless person_admin?
    end

end
