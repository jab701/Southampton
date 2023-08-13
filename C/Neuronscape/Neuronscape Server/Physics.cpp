#include "Physics.h"


// Default Constructor
PhysicsThread::PhysicsThread(wxFrame* Parent)  : wxThread(wxTHREAD_JOINABLE)
{
	this->m_Parent = Parent;
	this->m_ObjectDB = NULL;
	this->m_ClientDB = NULL;
	this->m_PhysTimeInterval = 0;
	this->m_Gravity = 0.0;
	this->m_EnvDim = CartesianVector(0.0,0.0,0.0);
}
// Destructor
PhysicsThread::~PhysicsThread()
{
	this->m_Parent = NULL;
	this->m_ObjectDB = NULL;
	this->m_ClientDB = NULL;
	this->m_PhysTimeInterval = 0;
	this->m_Gravity = 0.0;
	this->m_EnvDim = CartesianVector(0.0,0.0,0.0);

}
void PhysicsThread::Initialize(DB_Client *ClientDatabase, DB_Object *ObjectDatabase, unsigned PhysTimeInterval, double Gravity, CartesianVector EnvDim)
{
	this->m_ClientDB = ClientDatabase;
	this->m_ObjectDB = ObjectDatabase;
	this->m_PhysTimeInterval = PhysTimeInterval;
	this->m_Gravity = Gravity;
	this->m_EnvDim = EnvDim;
}
wxThread::ExitCode PhysicsThread::Entry()
{
	double timestep = this->m_PhysTimeInterval*1E-3;

	while(1)
	{
		if (this->TestDestroy())
		{
			wxLogMessage("Physics Thread Exit");
			break;
		}

		std::vector<DBRecord_Object> UpdatedObjects;

		if ((this->m_ClientDB != NULL)&&(this->m_ObjectDB != NULL)&&(this->m_Parent != NULL)&&(this->m_PhysTimeInterval != 0))
		{
			std::vector<DBRecord_Object> Objects;

			this->m_ObjectDB->FetchAllMobile(Objects);


			//******************************************************************************
			// Calculate where the objects would be if moving undisturbed by external events
			//******************************************************************************
			for (unsigned int i=0; i < Objects.size(); i++)
			{
				CartesianVector Position = Objects[i].Position;
				CartesianVector StartVelocity = Objects[i].Velocity;
				CartesianVector MotorForce = Objects[i].MotorForce;
				CartesianVector ExternForce = Objects[i].ExternForce;
				double Theta = Objects[i].Theta;
				double ThetaTorque = Objects[i].ThetaTorque;
				double StartThetaOmega = Objects[i].ThetaVelocity;

				CartesianVector FinishVelocity;
				CartesianVector FinishPosition;


				double FinishThetaOmega;
				double NewTheta;

				double AvailableEnergy = Objects[i].Energy;

				if (AvailableEnergy != AvailableEnergy)
				{
					continue;
				}
				this->CalculatePositionVelocity(timestep,Position,StartVelocity,MotorForce,ExternForce,FinishPosition,FinishVelocity,AvailableEnergy);
				this->CalculateRotation(timestep,1.0,ThetaTorque,Theta, StartThetaOmega,NewTheta,FinishThetaOmega,AvailableEnergy);

				//*************************************************
				// Work Done Calculations
				//*************************************************
				if (Objects[i].Client_ID != 0)
				{
					if (AvailableEnergy != AvailableEnergy)
					{
						continue;
					}
					if (AvailableEnergy < 1.0)
					{
						AvailableEnergy  = INITIAL_ENERGY;
					}
					// Update the database so that if the client doesnt send an energy update and we are out of energy we dont move!
					if	(DEBUG_ENERGY_DEPLETION_ON)
					{ // as a debug measure, allow disabling of energy loss due to movement
						this->m_ObjectDB->UpdateRecord_Energy(Objects[i].ID, AvailableEnergy);
					}
				}
				//*************************************************
				// Write back to the database
				//*************************************************
				this->m_ObjectDB->UpdateRecord_PositionVelocity(Objects[i].ID,FinishPosition,FinishVelocity);
				this->m_ObjectDB->UpdateRecord_Theta_ThetaVelocity(Objects[i].ID,NewTheta,FinishThetaOmega);


			}
			//*************************************************
			// send updates to clients
			//*************************************************
			std::vector<DBRecord_Client> Clients;
			std::vector<wxIPV4address> ClientAddresses;

			this->m_ClientDB->FetchAll(Clients);

			for (uint32_t i = 0; i < Clients.size(); i++)
			{
				ClientAddresses.push_back(Clients[i].Addr);
			}

			if (this->m_ObjectDB->IsDirty())
			{
				this->m_ObjectDB->FetchAll(Objects);
				this->m_ObjectDB->ClearDirtyBit();
			}
			else
			{
				this->m_ObjectDB->FetchAllMobile(Objects);
			}

			uint32_t NumPackets = (uint32_t) std::ceil((double)Objects.size()/MAX_OBJ_BULK_PKT);

			std::vector<std::string> BulkUpdatePackets;

			DBRecord_Object ObjectRecordsSubSet[MAX_OBJ_BULK_PKT];

			for (uint32_t i = 0; i < NumPackets; i++)
			{
				std::string Packet;
				int Counter = 0;
				for (uint32_t j = 0; ((j < MAX_OBJ_BULK_PKT)&&((j + (i*MAX_OBJ_BULK_PKT)) < Objects.size())); j++)
				{
					ObjectRecordsSubSet[j] = Objects[(i*MAX_OBJ_BULK_PKT)+j];
					Counter++;
				}
				this->PrepareBulkUpdatePacket(&Packet,Counter,ObjectRecordsSubSet);
				BulkUpdatePackets.push_back(Packet);
			}

			PhysicsEvent event (nsPHYSICSBULKUPDATE, ID_PHYSICSSENDBULKEVENT);
			event.SetAddresses(ClientAddresses);
			event.SetPayloads(BulkUpdatePackets);
			// Send an event to the main thread to signal that object updates must be sent!
			this->m_Parent->GetEventHandler()->AddPendingEvent(event);			
			// Sleep for phys interval time
			wxThread::Sleep(this->m_PhysTimeInterval);
		}
	}
	return (0);
}
void PhysicsThread::CalculatePositionVelocity(double TimeStep, CartesianVector StartPosition, CartesianVector StartVelocity, CartesianVector MotorForce, CartesianVector ExternForce, CartesianVector &FinishPosition, CartesianVector &FinishVelocity, double &AvailableEnergy)
{
	double Mass = MASS;
	double Radius = RADIUS;

	CartesianVector ForceDueToGravity = CartesianVector(0.0, 0.0, -this->m_Gravity) * Mass;
	CartesianVector Force = MotorForce + ExternForce + ForceDueToGravity;

	CartesianVector Friction;
	CartesianVector Displacement;

	// X Direction
	// If force in the X direction is 0 then we are coasting
	if (Force.x == 0.0)
	{
		if (PHYSICS_COASTING)
		{
			this->Coasting_PV(TimeStep, Mass, Radius, StartVelocity.x, FinishVelocity.x, Displacement.x);
		}
		else
		{
			FinishVelocity.x = 0.0;
			Displacement.x = 0.0;
		}
	}
	else
	{
		this->Powered_PV(TimeStep, Mass, Radius, Force.x, StartVelocity.x, FinishVelocity.x, Displacement.x, Friction.x);
	}

	// Y Direction
	// If force in the Y direction is 0 then we are coasting
	if (Force.y == 0.0)
	{		
		if (PHYSICS_COASTING)
		{
			this->Coasting_PV(TimeStep, Mass, Radius, StartVelocity.y, FinishVelocity.y, Displacement.y);
		}
		else
		{
			FinishVelocity.y = 0.0;
			Displacement.y = 0.0;
		}
	}
	else
	{
		this->Powered_PV(TimeStep, Mass, Radius, Force.y, StartVelocity.y, FinishVelocity.y, Displacement.y, Friction.y);
	}

	// Z Direction
	// If force in the Z direction is 0 then we are coasting
	if (Force.z == 0.0)
	{
		if (PHYSICS_COASTING)
		{

			this->Coasting_PV(TimeStep, Mass, Radius, StartVelocity.z, FinishVelocity.z, Displacement.z);
		}
		else
		{
			FinishVelocity.z = 0.0;
			Displacement.z = 0.0;
		}
	}
	else
	{
		this->Powered_PV(TimeStep, Mass, Radius, Force.z, StartVelocity.z, FinishVelocity.z, Displacement.z, Friction.z);
	}

	FinishPosition = StartPosition + Displacement;

	this->EnvBoundsCheck(FinishPosition, FinishVelocity, Radius, this->m_EnvDim);

	CartesianVector ActualDisplacement = FinishPosition - StartPosition;

	double WorkDone = this->CalculateMovementWorkDone(ActualDisplacement, MotorForce, Friction, ExternForce, Mass);

	if ((AvailableEnergy - WorkDone) < 0.0)
	{
		// There is not enough energy to perform the movement
		AvailableEnergy = 0.0;
	}
	else
	{

		AvailableEnergy -= WorkDone;

	}
}
void PhysicsThread::Coasting_PV(double TimeStep, double Mass, double Radius, double U, double &V, double &S)
{
	// calculate coasting position and velocity
	double U_Sign = GetSign(U);

	double Friction = -1.0 * U_Sign * mu_kinetic * Mass * this->m_Gravity;

	double A = Friction / Mass;

	if (U == 0.0)
	{
		V = 0.0;
	}
	else
	{
		V = U + A * TimeStep;

		if (!SameSign(U, V)) // If we are coasting our velocity cannot change direction
		{
			V = 0.0;
		}
	}

	S = (V + U * 0.5) * TimeStep;
}
void PhysicsThread::Powered_PV(double TimeStep, double Mass, double Radius, double Force, double U, double &V, double &S, double &Friction)
{
	double A;
	double ResultantForce;
	double Force_Sign = GetSign(Force);
	double U_Sign = GetSign(U);

	if (U == 0.0)
	{
		// We are dealing with Static Friction, Friction opposes the motor force
		Friction = -1.0 * Force_Sign * mu_static * Mass * this->m_Gravity;
		ResultantForce = Force + Friction;

		if (!SameSign(ResultantForce, Force))
			// If the resultant force is in the direction of friction then 
			// We cannot overcome static friction so we stay still
		{
			ResultantForce = 0.0;
			A = 0.0;
			S = 0.0;
			V = 0.0;
		}
		else
			// We can overcome static friction so we start accellerating
		{
			A = ResultantForce / Mass;
			V = U + A * TimeStep;
			S = ((V + U) * 0.5) * TimeStep;
		}
	}
	else
		// We are already moving, Friction opposes motion.
	{
		Friction = -1.0 * U_Sign * mu_kinetic * Mass * this->m_Gravity;

		A = (Force + Friction) / Mass;

		// Are friction and the motor force in the same direction?
		if (SameSign(Force, Friction))
		{
			// Force & Friction has the same sign. This means the object could stop and reverse
			// direction in this time step.
			V = U + A * TimeStep;
		}
		else
		{
			// Force and Friction are in opposition. If we are slowing down then we cant reverse direction
			V = U + A * TimeStep;

			if (!SameSign(U, V))
			{
				V = 0.0;
			}
		}

		S = ((V + U) * 0.5) * TimeStep;
	}
}
void PhysicsThread::CalculateRotation(double TimeStep, double EffRadius, double Torque, double StartTheta, double StartOmega, double &FinishTheta, double &FinishOmega, double &AvailableEnergy)
{
	double Mass = MASS;
	double Radius = RADIUS;

	double Friction = 0.0;
	double AngularDisplacement;

	if (Torque == 0.0)
	{
		if (PHYSICS_COASTING)
		{
			this->Coasting_Rotation(TimeStep, Mass, Radius, StartOmega, FinishOmega, AngularDisplacement);
		}
		else
		{
			FinishOmega = 0.0;
			AngularDisplacement = 0.0;
		}
	}
	else
	{
		this->Powered_Rotation(TimeStep, Mass, Radius, Torque, StartOmega, FinishOmega, AngularDisplacement, Friction);
	}

	double WorkDone = this->CalculateRotationWorkDone(Torque, Friction, AngularDisplacement);

	FinishTheta = StartTheta + AngularDisplacement;

	if (FinishTheta > 2.0 * PI)
	{
		FinishTheta -= 2.0 * PI;
	}

	if (FinishTheta < 0.0)
	{
		FinishTheta += 2.0 * PI;
	}

	if ((AvailableEnergy - WorkDone) < 0.0)
	{
		// There is not enough energy to perform the movement
		AvailableEnergy = 0.0;
	}
	else
	{
		AvailableEnergy -= WorkDone;
	}
}
void PhysicsThread::Coasting_Rotation(double TimeStep, double Mass, double Radius, double U, double &V, double &S)
{
	double U_Sign = GetSign(U);

	double Friction = -1.0 * U_Sign * mu_kinetic * Mass * this->m_Gravity;

	// Model object as a sphere and calculate interia
	double Inertia = (2.0 / 5.0) * Mass * Radius * Radius;
	double A = Friction / Inertia;

	if (U == 0.0)
	{
		V = 0.0;
	}
	else
	{
		V = U + A * TimeStep;

		if (!SameSign(U, V)) // If we are coasting our velocity cannot change direction
		{
			V = 0.0;
		}
	}

	S = (V + U * 0.5) * TimeStep;
}
void PhysicsThread::Powered_Rotation(double TimeStep, double Mass, double Radius, double Force, double U, double &V, double &S, double &Friction)
{
	double A;
	double ResultantForce;
	double Force_Sign = GetSign(Force);
	double U_Sign = GetSign(U);

	// Model object as a sphere and calculate interia
	double Inertia = (2.0 / 5.0) * Mass * Radius * Radius;

	if (U == 0.0)
	{
		// We are dealing with Static Friction, Friction opposes the motor force
		Friction = -1.0 * Force_Sign * mu_static * Mass * this->m_Gravity;
		ResultantForce = Force + Friction;

		if (!SameSign(ResultantForce, Force))
			// If the resultant force is in the direction of friction then 
			// We cannot overcome static friction so we stay still
		{
			ResultantForce = 0.0;
			A = 0.0;
			S = 0.0;
			V = 0.0;
		}
		else
			// We can overcome static friction so we start accellerating
		{
			A = ResultantForce / Inertia;
			V = U + A * TimeStep;
			S = ((V + U) * 0.5) * TimeStep;
		}
	}
	else
		// We are already moving, Friction opposes motion.
	{
		Friction = -1.0 * U_Sign * mu_kinetic * Mass * this->m_Gravity;

		A = (Force + Friction) / Inertia;

		// Are friction and the motor force in the same direction?
		if (SameSign(Force, Friction))
		{
			// Force & Friction has the same sign. This means the object could stop and reverse
			// direction in this time step.
			V = U + A * TimeStep;
		}
		else
		{
			// Force and Friction are in opposition. If we are slowing down then we cant reverse direction
			V = U + A * TimeStep;

			if (!SameSign(U, V))
			{
				V = 0.0;
			}
		}

		S = ((V + U) * 0.5) * TimeStep;
	}
}

void PhysicsThread::EnvBoundsCheck(CartesianVector &Position, CartesianVector &Velocity, double Radius, CartesianVector Bounds)
{
	//*********************************************************
	// Check that object is still within bounds of environment!
	//*********************************************************
	// Check x direction
	if ((Position.x - Radius) < 0.0)
	{
		Position.x = Radius; // Ensures whole object is within bounds
		Velocity.x = 0.0;
	}
	else if ((Position.x + Radius) > Bounds.x)
	{
		Position.x = (Bounds.x - Radius); // Ensures whole object is within bounds
		Velocity.x = 0.0;
	}

	// Check y direction
	if ((Position.y - Radius) < 0.0)
	{
		Position.y = Radius; // Ensures whole object is within bounds
		Velocity.y = 0.0;
	}
	else if ((Position.y + Radius) > Bounds.y)
	{
		Position.y = (Bounds.y - Radius); // Ensures whole object is within bounds
		Velocity.y = 0.0;
	}

	// Check z direction
	if ((Position.z - Radius) < 0.0)
	{
		Position.z = Radius; // Ensures whole object is within bounds
		Velocity.z = 0.0;
	}
	else if ((Position.z + Radius) > Bounds.z)
	{
		Position.z = (Bounds.z - Radius); // Ensures whole object is within bounds
		Velocity.z = 0.0;
	}
}
double PhysicsThread::CalculateMovementWorkDone(CartesianVector Displacement, CartesianVector MotorForce, CartesianVector Friction, CartesianVector ExternalForce, double Mass)
{
	CartesianVector ForceDueToGravity = CartesianVector(0.0, 0.0, -9.8) * Mass;
	CartesianVector MotorUnitVector = MotorForce.UnitVector();
	CartesianVector WorkDoneVector = MotorForce - Friction - ExternalForce - ForceDueToGravity;

	Displacement = Displacement.Abs();

	double WorkDoneX = MotorUnitVector.x * WorkDoneVector.x * Displacement.x;
	double WorkDoneY = MotorUnitVector.y * WorkDoneVector.y * Displacement.y;
	double WorkDoneZ = MotorUnitVector.z * WorkDoneVector.z * Displacement.z;

	double WorkDone = WorkDoneX + WorkDoneY + WorkDoneZ;

	return WorkDone;
}
double PhysicsThread::CalculateRotationWorkDone(double Torque, double TorqueFriction, double Displacement)
{
	double WorkDoneForce = 0.0;

	if (Torque != 0.0)
	{
		WorkDoneForce = Torque - TorqueFriction;
	}

	return (std::abs(WorkDoneForce*Displacement));
}
bool PhysicsThread::PrepareBulkUpdatePacket(std::string *PacketData, uint32_t NumObjects, DBRecord_Object ObjectRecords[])
{
	if ((NumObjects == 0)||(NumObjects > MAX_OBJ_BULK_PKT))
	{
		return false;
	}

	if ((PacketData == NULL)||(ObjectRecords == NULL))
	{
		return false;
	}

	std::vector<unsigned char> Code = ushort2uchar(PKT_BULK_UPDATE_OBJ);

	PacketData->append(Code.begin(),Code.end());

	std::vector<unsigned char> NumObjectsVect = ulong2uchar(NumObjects);
	PacketData->append(NumObjectsVect.begin(),NumObjectsVect.end());

	for (uint32_t i=0; i<NumObjects; i++)
	{
		uint32_t ID = ObjectRecords[i].ID;
		CartesianVector Position = ObjectRecords[i].Position;
		double Theta = ObjectRecords[i].Theta;
		double Phi = ObjectRecords[i].Phi;
		unsigned char Red = ObjectRecords[i].Red;
		unsigned char Green = ObjectRecords[i].Green;
		unsigned char Blue = ObjectRecords[i].Blue;
		unsigned char Brightness = ObjectRecords[i].Brightness;
		double Energy = ObjectRecords[i].Energy;
		uint16_t Flags = ObjectRecords[i].FLAGS;

		std::vector<unsigned char> ID_vec	 = ulong2uchar(ID);
		std::vector<unsigned char> X_vec	 = double2uchar(Position.x);
		std::vector<unsigned char> Y_vec	 = double2uchar(Position.y);
		std::vector<unsigned char> Z_vec	 = double2uchar(Position.z);
		std::vector<unsigned char> Theta_vec = double2uchar(Theta);
		std::vector<unsigned char> Phi_vec   = double2uchar(Phi);
		std::vector<unsigned char> Energy_vec   = double2uchar(Energy);
		std::vector<unsigned char> Flags_vec   = ushort2uchar(Flags);

		PacketData->append(ID_vec.begin(),ID_vec.end());
		PacketData->append(X_vec.begin(),X_vec.end());
		PacketData->append(Y_vec.begin(),Y_vec.end());
		PacketData->append(Z_vec.begin(),Z_vec.end());
		PacketData->append(Theta_vec.begin(),Theta_vec.end());
		PacketData->append(Phi_vec.begin(),Phi_vec.end());
		PacketData->push_back(Red);
		PacketData->push_back(Green);
		PacketData->push_back(Blue);
		PacketData->push_back(Brightness);
		PacketData->append(Energy_vec.begin(),Energy_vec.end());
		PacketData->append(Flags_vec.begin(), Flags_vec.end());
	}
	return true;
}