<template>
  <form class="container" @submit.prevent="submit">
    <h3 class="header">Записаться на ремонт</h3>
    <div class="field-block">
      <label class="label" for="carRegNumber">Гос №*</label
      ><input
        required
        class="input-field"
        id="carRegNumber"
        pattern="[А-Яа-яA-Za-z]{1}[0-9]{3}[А-Яа-яA-Za-z]{2}[0-9]{2,3}"
        placeholder="А999АА999"
        type="text"
        v-model="carRegNumber"
        @change="getCarInfo"
      />
      <span id="carRegNumberValid" class="input-pseudo"></span>
    </div>
    <div class="field-block">
      <label class="label" for="phone">Телефон*</label>

      <select name="" id="phoneCode" v-model="phoneCode">
        <option selected value="+7">+7</option>
        <option value="+372">+372</option></select
      ><input
        required
        type="tel"
        pattern="[0-9]{3}-?[0-9]{3}-?[0-9]{4}"
        placeholder="999-999-9999"
        id="phone"
        v-model="phone"
        @change="checkPhone()"
      />

      <span id="phoneValid" class="input-pseudo"></span>
    </div>

    <div class="field-block">
      <label class="label" for="ownerName">Имя*</label
      ><input
        required
        pattern="[А-Яа-яA-Za-z ]{3,}"
        class="input-field"
        type="text"
        id="ownerName"
        v-model="ownerName"
        @change="checkOwnerName()"
      />
      <span id="ownerNameValid" class="input-pseudo"></span>
    </div>

    <div class="field-block">
      <label class="label" for="station">Станция*</label
      ><select required class="input-field" id="station" v-model="station">
        <option :value="item" v-for="item in stations" :key="item.Id">
          {{ item.Name }}
        </option>
      </select>
      <span class="input-pseudo"></span>
    </div>
    <div class="field-block">
      <label class="label" for="mark">Марка*</label
      ><select
        required
        class="input-field"
        id="mark"
        v-model="mark"
        @change="getModelsByMark(String(mark.MARK_ID))"
      >
        <option :value="item" v-for="item in marks" :key="item.MARK_ID">
          {{ item.MARK_NAME_RUS }}
        </option>
      </select>
      <span class="input-pseudo"></span>
    </div>
    <div class="field-block">
      <label class="label" for="model">Модель*</label
      ><select required class="input-field" id="model" v-model="model">
        <option :value="item" v-for="item in models" :key="item.MODEL_ID">
          {{ item.MODEL_NAME }}
        </option>
      </select>
      <span class="input-pseudo"></span>
    </div>
    <div class="field-block">
      <label class="label" for="description">Что требуется сделать*</label
      ><textarea
        required
        class="input-field"
        cols="30"
        rows="10"
        id="description"
        v-model="description"
        @change="checkDescription()"
      >
      </textarea>
      <span id="descriptionValid" class="input-pseudo"></span>
    </div>
    <div class="field-block">
      <label class="label" for="confirmCost"
        >Предварительно согласовать стоимость</label
      ><input
        class="input-field"
        type="checkbox"
        id="confirmCost"
        v-model="confirmCost"
      />
      <span class="input-pseudo"></span>
    </div>
    <div class="field-block">
      <label class="label" for="date">Дата*</label
      ><input
        required
        class="input-field"
        type="date"
        :min="new Date().toISOString().split('T')[0]"
        :max="
          new Date(new Date().setMonth(new Date().getMonth() + 1))
            .toISOString()
            .split('T')[0]
        "
        id="date"
        v-model="date"
      />
      <span class="input-pseudo"></span>
    </div>
    <div class="field-block">
      <label class="label" for="timeHours">Время</label>
      <select
        id="timeHours"
        v-model="timeHours"
        @change="time = timeHours + ':' + timeMinutes"
      >
        <option
          v-for="i in [
            '08',
            '09',
            '10',
            '11',
            '12',
            '13',
            '14',
            '15',
            '16',
            '17',
            '18',
            '19',
            '20',
          ]"
          :key="i"
        >
          {{ i }}
        </option>
      </select>
      <span>:</span>
      <select
        id="timeMinutes"
        v-model="timeMinutes"
        @change="time = timeHours + ':' + timeMinutes"
      >
        <option v-for="i in ['00', '15', '30', '45']" :key="i">
          {{ i }}
        </option>
      </select>
      <span class="input-pseudo"></span>
    </div>
    <input type="submit" value="ЗАПИСАТЬСЯ" id="submit" />
  </form>
</template>

<script lang="ts">
import { MessageObject } from "@/App.vue";
import { defineComponent } from "vue";

interface Station {
  Id: number;
  Name: string;
}

interface Mark {
  MARK_ID: number;
  MARK_NAME_RUS: string;
  MARK_NAME_ENG: string;
}

interface Model {
  MODEL_ID: number;
  MODEL_NAME: string;
}

type ScheduledCarDataItem = {
  LDEPARTMENT_ID: number;
  CREATE_DATE: string;
  START: string;
  CLIENT_NAME: string;
  CLIENT_PHONE: string;
  GOSREG: string;
  DURATION: number;
  VIN?: string;
  MODEL_ID: number;
  COMMENT: string;
};

export default defineComponent({
  data() {
    return {
      carRegNumber: "",
      SESSIONID: "",
      VIN: "XWEHC812BA0001991",
      phoneCode: "+7",
      phone: "",
      ownerName: "",
      station: {} as Station,
      stations: new Array<Station>(),
      mark: {} as Mark,
      marks: new Array<Mark>(),
      model: {} as Model,
      models: new Array<Model>(),
      description: "",
      confirmCost: true,
      date: "",
      time: "08:00",
      timeHours: "08",
      timeMinutes: "00",
      authorizationIntervalID: 0,
    };
  },
  name: "MainPage",
  components: {},
  async created() {
    this.authorizationIntervalID = setInterval(() => {
      this.auth();
    }, 1200000);
    await this.auth();
    try {
      const URL = `https://zenon.basgroup.ru:55724/api-v2/Core/RW/Directories/LDepartmentsCombo?SESSIONID=${this.SESSIONID}`;
      const response = await fetch(URL);
      const data = await response.json();

      if (data.result.Status === 0) {
        this.stations = data.result.Response.LDepartmentsCombo.data;
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log(error.message);
      }
    }

    try {
      const URL = `https://zenon.basgroup.ru:55724/api-v2/Core/Directories/Marks?SESSIONID=${this.SESSIONID}`;
      const response = await fetch(URL);
      const data = await response.json();

      if (data.result.Status === 0) {
        this.marks = data.result.Response.Marks.data;
      }
    } catch (error) {
      if (error instanceof Error) {
        console.log(error.message);
      }
    }
  },

  methods: {
    async auth() {
      try {
        const username = "TEH_TEST";
        const password = "a1b2c3D$";
        const API_KEY = "92ae9e4c96394cf2aa2f462a5fde3b19";

        const LOGIN_URL = `https://zenon.basgroup.ru:55724/api-v2/auth/login?API_KEY=${API_KEY}`;

        let headers = new Headers();

        headers.set(
          "Authorization",
          "Basic " + btoa(username + ":" + password)
        );
        const response = await fetch(LOGIN_URL, {
          method: "GET",
          headers: headers,
        });

        const authData = await response.json();
        this.SESSIONID = authData.SESSIONID;
      } catch (error) {
        if (error instanceof Error) {
          console.log(error.message);
        }
      }
    },
    checkCarRegNumber() {
      this.carRegNumber = this.carRegNumber.trim().toUpperCase();
      this.check(
        "[А-Яа-яA-Za-z]{1}[0-9]{3}[А-Яа-яA-Za-z]{2}[0-9]{2,3}",
        this.carRegNumber,
        document.getElementById("carRegNumber") as HTMLElement
      );
    },

    checkPhone() {
      this.phone = this.phone.trim().replace(" ", "").replaceAll("-", "");
      this.check(
        "[0-9]{3}-?[0-9]{3}-?[0-9]{4}",
        this.phone,
        document.getElementById("phone") as HTMLElement
      );
    },

    checkOwnerName() {
      this.ownerName = this.ownerName.trim();
      this.check(
        "[А-Яа-яA-Za-z ]{3,}",
        this.ownerName,
        document.getElementById("ownerName") as HTMLElement
      );
    },

    checkDescription() {
      this.check(
        "[А-Яа-яA-Za-z ]{3,}",
        this.description,
        document.getElementById("description") as HTMLElement
      );
    },

    async getCarInfo() {
      this.checkCarRegNumber();
      const URL = `https://zenon.basgroup.ru:55724/api-v2/Core/Directories/CarsByGosreg/${this.carRegNumber}?SESSIONID=${this.SESSIONID}`;
      const response = await fetch(URL);
      if (response.status === 200) {
        const data = await response.json();
        if (
          data.result.Status === 0 &&
          data.result.Response.CarsByGosreg.data.length
        ) {
          const carData = data.result.Response.CarsByGosreg.data[0];
          this.ownerName = carData.POLICY_CAR_OWNER;
          this.checkOwnerName();
          const findMark = this.marks.find(
            (item) => item.MARK_NAME_RUS === carData.POLICY_MARK
          );
          if (findMark) {
            this.mark = findMark;
          }
          await this.getModelsByMark(
            String(
              this.marks.find(
                (item) => item.MARK_NAME_ENG === carData.POLICY_MARK
              )?.MARK_ID
            )
          );

          const findModel = this.models.find(
            (item) => item.MODEL_NAME === carData.POLICY_MODEL
          );
          if (findModel) {
            this.model = findModel;
          }
          const URL = `https://zenon.basgroup.ru:55724/api-v2/Core/Directories/Customer/${carData.PROPERTY_CUSTOMER_ID}?SESSIONID=${this.SESSIONID}`;
          const response = await fetch(URL);
          const responseData = await response.json();
          if (responseData.result.Status === 0) {
            const clientData = responseData.result.Response.Customer.data;
            this.phone = clientData.PHONE.substring(1);
            this.checkPhone();
            this.ownerName =
              clientData.FIRST_NAME + " " + clientData.SECOND_NAME;
          }
        } else {
          const URL = `https://zenon.basgroup.ru:55724/api-v2/ExtRequests/rsaExtended?SESSIONID=${this.SESSIONID}&GOSREG=${this.carRegNumber}`;
          const response = await fetch(URL);
          const data = await response.json();
          if (data.result.Status === 0) {
            const findMark = this.marks.find(
              (item) =>
                item.MARK_NAME_RUS === data.result.Response.rsaExtended.carMark
            );
            if (findMark) {
              this.mark = findMark;
            }
            await this.getModelsByMark(
              String(
                this.marks.find(
                  (item) =>
                    item.MARK_NAME_ENG ===
                    data.result.Response.rsaExtended.carMark
                )?.MARK_ID
              )
            );

            const findModel = this.models.find(
              (item) =>
                item.MODEL_NAME === data.result.Response.rsaExtended.carModel
            );
            if (findModel) {
              this.model = findModel;
            }

            this.ownerName = data.result.Response.rsaExtended.insurantFio;
          }
        }
      }
    },
    check(regexString: string, testString: string, target: HTMLElement) {
      const regex = new RegExp(regexString);
      const valid = regex.test(testString);
      if (target) {
        if (valid) {
          target.classList.remove("not-valid");
          target.classList.add("valid");
        } else {
          target.classList.add("not-valid");
          target.classList.remove("valid");
        }
      }
    },
    clearForm() {
      this.carRegNumber = "";
      this.ownerName = "";
      this.phone = "";
      this.station = {} as Station;
      this.mark = {} as Mark;
      this.model = {} as Model;
      this.description = "";
      this.confirmCost = true;
      this.date = "";
      this.timeHours = "08";
      this.timeMinutes = "00";
      this.time = "08:00";
      document.getElementById("carRegNumber")?.classList.remove("valid");
      document.getElementById("ownerName")?.classList.remove("valid");
      document.getElementById("phone")?.classList.remove("valid");
      document.getElementById("description")?.classList.remove("valid");
    },
    async getModelsByMark(markId: string) {
      const URL = `https://zenon.basgroup.ru:55724/api-v2/Core/Directories/ModelsCombo/${markId}?SESSIONID=${this.SESSIONID}`;
      const response = await fetch(URL);
      const data = await response.json();

      this.models = data.result.Response.ModelsCombo.data;
    },
    async submit() {
      const formData: ScheduledCarDataItem = {
        CLIENT_NAME: this.ownerName,
        CLIENT_PHONE: this.phoneCode.concat(this.phone),
        LDEPARTMENT_ID: this.station.Id,
        CREATE_DATE: this.date + " " + this.time + ":00",
        START: this.date + " " + this.time + ":00",
        DURATION: 1,
        GOSREG: this.carRegNumber,
        MODEL_ID: this.model.MODEL_ID,
        COMMENT: this.description,
      };
      const URL = `https://zenon.basgroup.ru:55724/api-v2/Core/RW/ScheduledCar?SESSIONID=${this.SESSIONID}`;
      const response = await fetch(URL, {
        method: "POST",
        body: JSON.stringify(formData),
      });
      const data = await response.json();
      if (data.result.Status === 0) {
        const sheduleData = data.result.Response.ScheduledCar.data;
        data.result.Response.ScheduledCar.data.START;
        data.result.Response.ScheduledCar.data.SCHEDULE_ID;
        data.result.Response.ScheduledCar.data.WRITER_NAME;
        this.setMessage({
          header: "Вы записаны!",
          text: `Время записи: ${sheduleData.START}.\nВаш ID: ${sheduleData.SCHEDULE_ID}.\nВаш менеджер: ${sheduleData.WRITER_NAME}`,
        });
        this.clearForm();
      } else {
        this.setMessage({
          header: `Не удалось записаться`,
          text: "Попробуйте выбрать другое время",
        });
      }
    },
    setMessage(messageOblect: MessageObject) {
      this.$emit("message", messageOblect);
    },
  },
});
</script>

<style scoped>
.container {
  padding: 10px;
}

.field-block {
  display: flex;
  justify-content: flex-end;
  margin: 0 auto;
  margin-bottom: 10px;
  align-items: center;
}
.label {
  display: block;
  width: 140px;
  margin-right: 30px;
  margin-right: auto;
  text-align: end;
}

.field-block:nth-child(8) > .label {
  align-self: flex-start;
}

.input-field {
  width: 200px;
}

#phoneCode {
  width: 60px;
}

#phone {
  width: 140px;
}
.input-pseudo {
  display: block;
  width: 15px;
  height: 12px;
  border: none;
  margin-left: 10px;
}

#carRegNumber.not-valid {
  border-color: red;
}

#carRegNumber.valid + #carRegNumberValid {
  border: 2px solid green;
  border-width: 0 0 2px 2px;
  transform: rotate(-45deg);
}

#phone.not-valid {
  border-color: red;
}
#phone.valid + #phoneValid {
  border: 2px solid green;
  border-width: 0 0 2px 2px;
  transform: rotate(-45deg);
}

#ownerName.not-valid {
  border-color: red;
}
#ownerName.valid + #ownerNameValid {
  border: 2px solid green;
  border-width: 0 0 2px 2px;
  transform: rotate(-45deg);
}
#description {
  resize: none;
}
#description.not-valid {
  border-color: red;
}
#description.valid + #descriptionValid {
  border: 2px solid green;
  border-width: 0 0 2px 2px;
  transform: rotate(-45deg);
}
#confirmCost {
  width: auto;
  margin-right: 187px;
}
#date {
  width: 120px;
  margin-right: 80px;
}

#timeHours {
  width: 50px;
  margin-right: 8px;
}
#timeMinutes {
  margin-left: 8px;
  width: 50px;
  margin-right: 80px;
}

#submit {
  margin-top: 15px;
  padding: 10px 20px;
  border: none;
  background-color: darkseagreen;
  border-radius: 5px;
  box-shadow: 3px 3px 5px rgba(0, 0, 0, 0.5);
}
</style>
