namespace com.training;

using {cuid, Country} from '@sap/cds/common';

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

type EmailsAddresses_01 : array of {
    kind  : String;
    email : String;
}

type EmailsAddresses_02 : {
    kind  : String;
    email : String;
}

type Emails             : {
    email_01  :      EmailsAddresses_01;
    email_02  : many EmailsAddresses_02;
    email_03  : many {
        kind  :      String;
        email :      String;
    };
}

type Gender             : String enum {
    male;
    female;
}

entity Order {
    clientGender : Gender;
    status       : Integer enum {
        submitted = 1;
        fulfiller = 2;
        shipped   = 3;
        cancel    = -1;
    };
    priority     : String @Assert.range enum {
        high;
        medium;
        low;
    }
}

/*
entity Car {
    ID                 : UUID;
    Name               : String;
    virtual discount_1 : Decimal;
    @Core.Computed
    virtual discount_2 : Decimal;
}
*/

/*
// Entities With parameters in selection
entity ParamProducts(Pname : String)     as
    select from Products {
        Name,
        Price,
        Quantity
    }
    where
        Name = : Pname;

// Entities With parameters in projections
entity ProjParamProducts(Pname : String) as projection on Products where Name = : Pname;
*/

entity Course : cuid {
    Student : Association to many StudentCourse
                  on Student.Course = $self;
}

entity Student : cuid {
    Course : Association to many StudentCourse
                 on Course.Student = $self;
}

entity StudentCourse : cuid {
    Student : Association to Student;
    Course  : Association to Course;
}

entity Orders {
    key ClientEmail : String(65);
        FirstName   : String(30);
        LastName    : String(30);
        CreatedOn   : Date;
        Reviewed    : Boolean;
        Approved    : Boolean;
        Country     : Country;
        Status      : String(1);
}
