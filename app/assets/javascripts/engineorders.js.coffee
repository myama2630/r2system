# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  $('#engineorder_new_engine_attributes_engine_model_name').change(updateSerialnoOptions)

@updateSerialnoOptions = () ->
  $.ajax(
    url: '/engines/serialno_list',
    type: 'GET',
    dataType: 'json'
    data:
      engine_model_name: $('#engineorder_new_engine_attributes_engine_model_name').val(),
    success: (response) -> setSerialnoOptions(response),
    error: (response) -> alert('シリアルNo.情報が取得できません'))

@setSerialnoOptions = (response) ->
  options = "<option value=''></option>"
  options += "<option value='#{serialno}'>#{serialno}</option>" for serialno in response
  $('#engineorder_new_engine_attributes_serialno>option').remove()
  $('#engineorder_new_engine_attributes_serialno').append(options)
