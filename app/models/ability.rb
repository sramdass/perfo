class Ability
  include CanCan::Ability
  
  def initialize(profile)
	@profile = profile
	#Without a valid profile, no one can do anything.
	if !@profile
	  return
	end
	#---------TEMPORARY--------------#
	#can :manage, :all
	#return
	#---------TEMPORARY--------------#
	@user_type = @profile.user_type
	#All the aliases come here
	#All the create, update and destroy actions should have read permissions. Include them in the aliases itself
	alias_action :new, :read, :to => :create
	alias_action :edit, :read,:to => :update
	@profile.roles.each do |role|
	  Resource.all.each do |res|
	    res.resource_actions.each do |ra|
	      if role.has_privilege?(res.id, ra.code)
	        send("#{res.name.downcase}_#{ra.name}") # This will be like --> faculty_section_read
          end
	    end
	  end
	end
  end #end of def initialize(profile)
  
  def exam_read
    can :read, Exam
  end
  
  def exam_edit
  	can :update, Exam
  end
    
  def exam_create
    can :create, Exam
  end
  
  def exam_destroy
  	can :destroy, Exam
  end

end
